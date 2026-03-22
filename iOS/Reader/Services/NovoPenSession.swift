@preconcurrency import CoreNFC
import Foundation

final class NovoPenSession {
    private let maxReadSize = 255
    private let maxHistoryPassCount = 6
    private let transportPause = Duration.milliseconds(20)
    private let options: ReaderOptions
    private let onEvent: @Sendable (String) -> Void
    private let onProgress: @Sendable (Int, Int?) -> Void
    private var sequence = 1
    
    init(
        options: ReaderOptions = ReaderOptions(),
        onProgress: @escaping @Sendable (Int, Int?) -> Void = { _, _ in },
        onEvent: @escaping @Sendable (String) -> Void = { _ in }
    ) {
        self.options = options
        self.onProgress = onProgress
        self.onEvent = onEvent
    }
    
    func readPen(using transceiver: any NovoPenTransceiver) async throws -> PenReading {
        let initialReading = try await readSinglePass(using: transceiver)
        
        guard options.receivesFullHistory else {
            return initialReading
        }
        
        return try await retrieveFullHistory(
            startingWith: initialReading,
            using: transceiver
        )
    }
    
    private func readSinglePass(using transceiver: any NovoPenTransceiver) async throws -> PenReading {
        sequence = 1
        
        if transceiver.isApplicationPreselected {
            onEvent("Skipping pen NFC application select because the AID is already preselected")
        } else {
            onEvent("Selecting pen NFC application")
            _ = try await readResult(NovoPenProtocol.applicationSelect(), using: transceiver)
        }
        
        onEvent("Selecting capability container")
        _ = try await readResult(NovoPenProtocol.capabilityContainerSelect(), using: transceiver)
        _ = try await readResult(NovoPenProtocol.readBinary(offset: 0, length: 15), using: transceiver)
        onEvent("Selecting NDEF file")
        _ = try await readResult(NovoPenProtocol.selectNDEF(), using: transceiver)
        
        return try await retrieveConfiguration(using: transceiver)
    }
    
    private func retrieveConfiguration(using transceiver: any NovoPenTransceiver) async throws -> PenReading {
        onEvent("Reading pen configuration")
        let lengthResult = try await readResult(NovoPenProtocol.readBinary(offset: 0, length: 2), using: transceiver)
        var lengthReader = ByteReader(data: lengthResult.content)
        let length = Int(try lengthReader.readUInt16())
        
        let fullRead = try await readResult(NovoPenProtocol.readBinary(offset: 2, length: length), using: transceiver)
        _ = try await readResult(NovoPenProtocol.acknowledgement(), using: transceiver)
        
        var packetReader = ByteReader(data: fullRead.content)
        let phdPacket = try PhdPacket(reader: &packetReader)
        let requestApdu = try Apdu(data: phdPacket.content)
        
        guard requestApdu.at == Apdu.aarq else {
            throw NovoPenError.malformedPacket("The pen did not return an AARQ packet")
        }
        
        var aRequestReader = ByteReader(data: requestApdu.payload)
        let aRequest = try ARequest(reader: &aRequestReader)
        
        let handshake = Apdu(
            at: Apdu.aare,
            payload: AResponse(
                result: 3,
                protocolIdentifier: ApoepElement.protocolIdentifier,
                apoep: aRequest.apoep
            ).encoded()
        )
        
        onEvent("Performing APDU handshake")
        let response = try await sendApduRequest(handshake, using: transceiver)
        let responseApdu = try Apdu(data: response)
        var responseDataApduReader = ByteReader(data: responseApdu.payload)
        let responseDataApdu = try DataApdu(reader: &responseDataApduReader)
        let configurationEvent = try responseDataApdu.eventReport()
        let configuration = configurationEvent?.configuration
        
        guard let configuration else {
            throw NovoPenError.missingConfiguration
        }
        
        onEvent("Configuration received")
        let actionHandles = configuration.candidateActionHandles.map(String.init).joined(separator: ", ")
        onEvent(
            "Configuration summary id=\(configuration.id) storeHandle=\(configuration.handle) " +
            "segments=\(configuration.numberOfSegments) entries=\(configuration.totalEntries) " +
            "actionHandles=\(actionHandles)"
        )
        _ = try await sendApduRequest(
            NovoPenProtocol.retrieveInformation(invokeID: responseDataApdu.invokeID, configuration: configuration),
            using: transceiver
        )
        
        onEvent("Requesting pen metadata")
        let fullSpecification = try await retrieveFullSpecification(
            invokeID: responseDataApdu.invokeID,
            configuration: configuration,
            metadataHandle: configurationEvent?.handle ?? 0,
            using: transceiver
        )
        
        let segments = try await retrieveSegments(
            invokeID: responseDataApdu.invokeID,
            configuration: configuration,
            using: transceiver
        )
        
        guard !segments.isEmpty else {
            throw NovoPenError.missingSegmentInfo
        }
        
        let capturedAt = Date()
        let doses = try await readDoseHistory(
            from: segments,
            configuration: configuration,
            invokeID: responseDataApdu.invokeID,
            using: transceiver
        )
        
        return PenReading(
            model: fullSpecification?.model.joined(separator: " ") ?? "",
            serial: fullSpecification?.specification.serial ?? "",
            capturedAt: capturedAt,
            penTimeSeconds: fullSpecification?.relativeTime ?? 0,
            doses: doses
        )
    }
    
    private func retrieveFullHistory(
        startingWith initialReading: PenReading,
        using transceiver: any NovoPenTransceiver
    ) async throws -> PenReading {
        var mergedReading = initialReading
        
        for pass in 2 ... maxHistoryPassCount {
            onEvent("Starting additional history pass \(pass)")
            
            do {
                let reading = try await readSinglePass(using: transceiver)
                let nextReading = mergeReadings(mergedReading, with: reading)
                let addedCount = nextReading.doses.count - mergedReading.doses.count
                
                if addedCount == 0 {
                    onEvent("Additional history pass \(pass) added no new doses")
                    break
                }
                
                onEvent("Additional history pass \(pass) added \(addedCount) doses")
                mergedReading = nextReading
            } catch {
                onEvent("Additional history pass \(pass) failed: \(error.localizedDescription)")
                break
            }
        }
        
        return mergedReading
    }
    
    private func mergeReadings(_ lhs: PenReading, with rhs: PenReading) -> PenReading {
        PenReading(
            model: lhs.model.isEmpty ? rhs.model : lhs.model,
            serial: lhs.serial.isEmpty ? rhs.serial : lhs.serial,
            capturedAt: lhs.capturedAt,
            penTimeSeconds: lhs.penTimeSeconds == 0 ? rhs.penTimeSeconds : lhs.penTimeSeconds,
            doses: mergeDoses(lhs.doses, rhs.doses)
        )
    }
    
    private func mergeDoses(_ lhs: [DoseEntry], _ rhs: [DoseEntry]) -> [DoseEntry] {
        var merged: [DoseEntry] = []
        var seen = Set<DoseIdentity>()
        
        for dose in (lhs + rhs).sorted(by: { $0.timestamp > $1.timestamp }) {
            let identity = DoseIdentity(timestamp: dose.timestamp, rawUnits: dose.rawUnits)
            
            guard seen.insert(identity).inserted else {
                continue
            }
            
            merged.append(dose)
        }
        
        return merged
    }
    
    private func readSegment(
        label: String,
        transferApdu: Apdu,
        expectedSegmentID: Int?,
        expectedDoseCount: Int?,
        invokeID: Int,
        using transceiver: any NovoPenTransceiver
    ) async throws -> [DoseEntry] {
        let transferResponse = try await sendApduRequest(
            transferApdu,
            using: transceiver
        )
        var result = try validateTransferStart(
            transferResponse,
            label: label,
            expectedSegmentID: expectedSegmentID
        )
        
        var doses: [DoseEntry] = []
        var finished = false
        
        while !finished {
            if result.isEmpty {
                result = try await sendEmptyRequest(using: transceiver)
            }
            
            let apdu = try Apdu(data: result)
            var dataApduReader = ByteReader(data: apdu.payload)
            let dataApdu = try DataApdu(reader: &dataApduReader)
            
            guard let report = try dataApdu.eventReport() else {
                finished = true
                continue
            }
            
            let reportCapturedAt = Date()
            let reportDoses = report.insulinDoses.map {
                DoseEntry(
                    timestamp: $0.resolvedDate(relativeTime: report.relativeTime, currentTime: reportCapturedAt),
                    rawUnits: $0.units
                )
            }
            doses.append(contentsOf: reportDoses)
            onEvent("Received \(reportDoses.count) doses, total \(doses.count)")
            onProgress(doses.count, expectedDoseCount)
            
            if !options.receivesFullHistory {
                onEvent("Stopping after the latest dose batch because full history mode is disabled")
                finished = true
                continue
            }
            
            if let expectedDoseCount,
               expectedDoseCount > 0,
               doses.count >= expectedDoseCount {
                onEvent("Received complete dose history with \(doses.count) doses")
                finished = true
                continue
            }
            
            if report.insulinDoses.isEmpty {
                finished = true
                continue
            }
            
            let acknowledgement = NovoPenProtocol.confirmedTransfer(
                invokeID: dataApdu.invokeID,
                data: NovoPenProtocol.eventRequestData(
                    instance: report.instance,
                    index: report.index,
                    count: report.insulinDoses.count,
                    confirmed: true
                )
            )
            
            result = try await sendApduRequest(acknowledgement, using: transceiver)
        }
        
        return doses
    }
    
    private func readDoseHistory(
        from segments: [SegmentInfo],
        configuration: Configuration,
        invokeID: Int,
        using transceiver: any NovoPenTransceiver
    ) async throws -> [DoseEntry] {
        var lastError: Error?
        let probes = buildTransferProbes(from: segments, configuration: configuration, invokeID: invokeID)
        
        for probe in probes {
            onEvent("Trying dose history variant \(probe.label)")
            
            do {
                return try await readSegment(
                    label: probe.label,
                    transferApdu: probe.apdu,
                    expectedSegmentID: probe.expectedSegmentID,
                    expectedDoseCount: configuration.totalEntries > 0 ? configuration.totalEntries : nil,
                    invokeID: invokeID,
                    using: transceiver
                )
            } catch {
                if shouldStopSegmentProbing(after: error) {
                    throw error
                }
                
                lastError = error
                onEvent("Variant \(probe.label) failed: \(error.localizedDescription)")
            }
        }
        
        throw lastError ?? NovoPenError.missingSegmentInfo
    }
    
    private func readResult(
        _ command: Data,
        using transceiver: any NovoPenTransceiver
    ) async throws -> NovoPenTransceiveResult {
        let response = try await transceiver.transceive(command)
        try await pauseForTransportIfNeeded()
        
        guard response.count >= 2 else {
            throw NovoPenError.malformedPacket("The pen returned an empty response")
        }
        
        let content = response.dropLast(2)
        let statusWord = (Int(response[response.count - 2]) << 8) | Int(response[response.count - 1])
        
        guard statusWord == NovoPenProtocol.commandCompleted else {
            throw NovoPenError.invalidStatusWord(statusWord)
        }
        
        return NovoPenTransceiveResult(
            content: Data(content),
            isSuccess: true
        )
    }
    
    private func pauseForTransportIfNeeded() async throws {
        guard options.receivesFullHistory else {
            return
        }
        
        try await Task.sleep(for: transportPause)
    }
    
    private func sendEmptyRequest(using transceiver: any NovoPenTransceiver) async throws -> Data {
        try await sendRequest(Data(), using: transceiver)
    }
    
    private func sendApduRequest(
        _ apdu: Apdu,
        using transceiver: any NovoPenTransceiver
    ) async throws -> Data {
        try await sendRequest(apdu.encoded(), using: transceiver)
    }
    
    private func sendRequest(
        _ data: Data,
        using transceiver: any NovoPenTransceiver
    ) async throws -> Data {
        let packet = PhdPacket(sequence: sequence, content: data)
        _ = try await readResult(NovoPenProtocol.t4Update(packet.encoded()), using: transceiver)
        
        let readLengthResult = try await readResult(NovoPenProtocol.readBinary(offset: 0, length: 2), using: transceiver)
        var readLengthReader = ByteReader(data: readLengthResult.content)
        let readLength = Int(try readLengthReader.readUInt16())
        
        let sizes = decomposedSizes(readLength)
        var combined = Data()
        
        for (index, size) in sizes.enumerated() {
            let chunk = try await readResult(
                NovoPenProtocol.readBinary(offset: 2 + (index * maxReadSize), length: size),
                using: transceiver
            )
            combined.append(chunk.content)
        }
        
        var combinedReader = ByteReader(data: combined)
        let responsePacket = try PhdPacket(reader: &combinedReader)
        sequence = responsePacket.sequence + 1
        
        _ = try await readResult(NovoPenProtocol.acknowledgement(), using: transceiver)
        return responsePacket.content
    }
    
    private func decodeFullSpecification(from data: Data) throws -> FullSpecification {
        let apdu = try Apdu(data: data)
        var dataApduReader = ByteReader(data: apdu.payload)
        let dataApdu = try DataApdu(reader: &dataApduReader)
        
        guard let fullSpecification = try dataApdu.fullSpecification() else {
            throw NovoPenError.malformedPacket("The pen did not return specification data")
        }
        
        return fullSpecification
    }
    
    private func retrieveFullSpecification(
        invokeID: Int,
        configuration: Configuration,
        metadataHandle: Int,
        using transceiver: any NovoPenTransceiver
    ) async throws -> FullSpecification? {
        for handle in [metadataHandle, configuration.handle] where handle >= 0 {
            onEvent("Requesting pen metadata using handle \(handle)")
            
            let data = try await sendApduRequest(
                NovoPenProtocol.askInformation(invokeID: invokeID, handle: handle),
                using: transceiver
            )
            let apdu = try Apdu(data: data)
            
            guard apdu.at == Apdu.prst else {
                onEvent("Metadata request for handle \(handle) returned \(apdu.typeName)")
                continue
            }
            
            if let fullSpecification = try? decodeFullSpecification(from: data) {
                return fullSpecification
            }
            
            onEvent("Metadata request for handle \(handle) did not return specification data")
        }
        
        onEvent("Metadata request returned no usable specification, continuing without pen metadata")
        return nil
    }
    
    private func retrieveSegments(
        invokeID: Int,
        configuration: Configuration,
        using transceiver: any NovoPenTransceiver
    ) async throws -> [SegmentInfo] {
        for handle in configuration.candidateActionHandles {
            onEvent("Requesting segment info using handle \(handle)")
            
            let data = try await sendApduRequest(
                NovoPenProtocol.confirmedAction(invokeID: invokeID, handle: handle),
                using: transceiver
            )
            let apdu = try Apdu(data: data)
            
            guard apdu.at == Apdu.prst else {
                onEvent("Segment info request for handle \(handle) returned \(apdu.typeName)")
                continue
            }
            
            do {
                let segmentInfoList = try decodeSegmentInfoList(from: data)
                
                if !segmentInfoList.items.isEmpty {
                    onEvent("Received \(segmentInfoList.items.count) segment(s) using handle \(handle)")
                    return segmentInfoList.items
                }
                
                onEvent("Segment info request for handle \(handle) returned no segments")
            } catch {
                onEvent("Segment info request for handle \(handle) could not be decoded: \(error.localizedDescription)")
            }
        }
        
        onEvent("Segment info request returned no usable segment info, trying transfer variants")
        return fallbackSegments(from: configuration)
    }
    
    private func fallbackSegments(from configuration: Configuration) -> [SegmentInfo] {
        var segmentIDs: [Int] = []
        let count = max(configuration.numberOfSegments, 1)
        let standardSegmentIDs = (0 ..< count).map { 0x0010 + $0 }
        let lowSegmentIDs = Array(0 ... min(count, 1) + 1)
        let objectHandleCandidates = configuration.objectHandles.filter { $0 >= 0 && $0 != configuration.handle }
        
        for candidate in [1, 0] + standardSegmentIDs + objectHandleCandidates {
            if !segmentIDs.contains(candidate) {
                segmentIDs.append(candidate)
            }
        }
        
        for candidate in lowSegmentIDs {
            if !segmentIDs.contains(candidate) {
                segmentIDs.append(candidate)
            }
        }
        
        let joinedSegmentIDs = segmentIDs.map(String.init).joined(separator: ", ")
        onEvent("Using fallback segment ids: \(joinedSegmentIDs)")
        return segmentIDs.map {
            SegmentInfo(
                instanceNumber: $0,
                usage: -1,
                items: [],
                segmentInfoMap: nil
            )
        }
    }
    
    private func validateTransferStart(
        _ data: Data,
        label: String,
        expectedSegmentID: Int?
    ) throws -> Data {
        let apdu = try Apdu(data: data)
        
        guard apdu.at == Apdu.prst else {
            throw NovoPenError.malformedPacket("\(label) returned \(apdu.typeName)")
        }
        
        var dataApduReader = ByteReader(data: apdu.payload)
        let dataApdu = try DataApdu(reader: &dataApduReader)
        
        if let report = try dataApdu.eventReport(),
           report.eventType == EventReport.segmentDataNotification {
            onEvent("\(label) started streaming data immediately")
            return data
        }
        
        guard let transfer = try dataApdu.triggerSegmentDataTransfer() else {
            throw NovoPenError.malformedPacket("\(label) did not return a transfer confirmation")
        }
        
        guard transfer.isOkay else {
            if let expectedSegmentID {
                throw NovoPenError.malformedPacket(
                    "\(label) rejected segment \(expectedSegmentID) with response code \(transfer.responseCode)"
                )
            }
            
            throw NovoPenError.malformedPacket(
                "\(label) was rejected with response code \(transfer.responseCode)"
            )
        }
        
        if let expectedSegmentID,
           transfer.segmentID != expectedSegmentID,
           transfer.segmentID != 0 {
            onEvent("\(label) confirmed segment \(transfer.segmentID) instead of \(expectedSegmentID)")
        }
        
        return Data()
    }
    
    private func shouldStopSegmentProbing(after error: Error) -> Bool {
        if let penError = error as? NovoPenError {
            switch penError {
            case .cancelled, .transportEnded:
                return true
            case .malformedPacket:
                return false
            default:
                return false
            }
        }
        
        let nsError = error as NSError
        
        if nsError.domain == NFCReaderError.errorDomain {
            return true
        }
        
        return false
    }
    
    private func decodeSegmentInfoList(from data: Data) throws -> SegmentInfoList {
        let apdu = try Apdu(data: data)
        var dataApduReader = ByteReader(data: apdu.payload)
        let dataApdu = try DataApdu(reader: &dataApduReader)
        
        guard let segmentInfoList = try dataApdu.segmentInfoList() else {
            throw NovoPenError.missingSegmentInfo
        }
        
        return segmentInfoList
    }
    
    private func decomposedSizes(_ value: Int) -> [Int] {
        let times = value / maxReadSize
        let remainder = value % maxReadSize
        var parts = Array(repeating: maxReadSize, count: times)
        
        if remainder != 0 {
            parts.append(remainder)
        }
        
        return parts
    }
    
    private func buildTransferProbes(
        from segments: [SegmentInfo],
        configuration: Configuration,
        invokeID: Int
    ) -> [(label: String, apdu: Apdu, expectedSegmentID: Int?)] {
        let segmentIDs = segments.map(\.instanceNumber)
        let actionHandles = configuration.candidateActionHandles
        var probes: [(label: String, apdu: Apdu, expectedSegmentID: Int?)] = []
        
        func appendProbe(label: String, apdu: Apdu, expectedSegmentID: Int?) {
            if !probes.contains(where: { $0.label == label }) {
                probes.append((label, apdu, expectedSegmentID))
            }
        }
        
        for handle in actionHandles {
            appendProbe(
                label: "handle \(handle) all segments",
                apdu: NovoPenProtocol.transferAllSegmentsAction(invokeID: invokeID, handle: handle),
                expectedSegmentID: nil
            )
        }
        
        for segmentID in segmentIDs.prefix(3) {
            appendProbe(
                label: "handle \(configuration.handle) segment \(segmentID)",
                apdu: NovoPenProtocol.transferAction(
                    invokeID: invokeID,
                    handle: configuration.handle,
                    segment: segmentID
                ),
                expectedSegmentID: segmentID
            )
        }
        
        for handle in actionHandles where handle != configuration.handle {
            for segmentID in [1, 0] {
                appendProbe(
                    label: "handle \(handle) segment \(segmentID)",
                    apdu: NovoPenProtocol.transferAction(
                        invokeID: invokeID,
                        handle: handle,
                        segment: segmentID
                    ),
                    expectedSegmentID: segmentID
                )
            }
        }
        
        if let firstHandleBackedSegment = configuration.objectHandles.first(where: { $0 > 0 }) {
            appendProbe(
                label: "handle \(configuration.handle) segment \(firstHandleBackedSegment)",
                apdu: NovoPenProtocol.transferAction(
                    invokeID: invokeID,
                    handle: configuration.handle,
                    segment: firstHandleBackedSegment
                ),
                expectedSegmentID: firstHandleBackedSegment
            )
        }
        
        let labels = probes.map(\.label).joined(separator: ", ")
        onEvent("Using transfer variants: \(labels)")
        return probes
    }
}
