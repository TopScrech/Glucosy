@preconcurrency import CoreNFC
import Foundation

final class CoreNFCPenScanner: NSObject, NFCTagReaderSessionDelegate {
    private let options: ReaderOptions
    private let onEvent: @Sendable (String) -> Void
    private var continuation: CheckedContinuation<PenReading, Error>?
    private var session: NFCTagReaderSession?
    private var isCompleted = false
    
    init(options: ReaderOptions, onEvent: @escaping @Sendable (String) -> Void = { _ in }) {
        self.options = options
        self.onEvent = onEvent
    }
    
    static var isReadingAvailable: Bool {
        NFCTagReaderSession.readingAvailable
    }
    
    func readPen() async throws -> PenReading {
        guard Self.isReadingAvailable else {
            throw NovoPenError.nfcUnavailable
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            guard let session = NFCTagReaderSession(
                pollingOption: [.iso14443, .iso15693],
                delegate: self,
                queue: nil
            ) else {
                continuation.resume(throwing: NovoPenError.nfcUnavailable)
                return
            }
            session.alertMessage = String(localized: "Hold your NovoPen near the top of your iPhone")
            self.session = session
            self.onEvent("Started NFC session")
            session.begin()
        }
    }
    
    nonisolated func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        onEvent("NFC session became active")
    }
    
    nonisolated func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        Task { @MainActor in
            guard !isCompleted, let continuation else {
                return
            }
            
            let nsError = error as NSError
            if nsError.domain == NFCReaderError.errorDomain,
               nsError.code == NFCReaderError.readerSessionInvalidationErrorUserCanceled.rawValue {
                self.onEvent("Session cancelled")
                continuation.resume(throwing: NovoPenError.cancelled)
            } else {
                self.onEvent("Session invalidated: \(error.localizedDescription)")
                continuation.resume(throwing: error)
            }
            
            isCompleted = true
            self.continuation = nil
            self.session = nil
        }
    }
    
    nonisolated func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        onEvent("Detected \(tags.count) tag(s)")
        let sessionBox = UncheckedSendableBox(value: session)
        
        guard let tag = tags.first else {
            Task { @MainActor in
                self.finish(with: .failure(NovoPenError.unsupportedTag), session: sessionBox.value)
            }
            return
        }
        
        guard tags.count == 1 else {
            session.alertMessage = String(localized: "Present only one pen at a time")
            session.restartPolling()
            return
        }
        
        let tagBox = UncheckedSendableBox(value: tag)
        
        session.connect(to: tag) { error in
            Task { @MainActor in
                if let error {
                    self.onEvent("Failed to connect to tag: \(error.localizedDescription)")
                    self.finish(with: .failure(error), session: sessionBox.value)
                    return
                }
                
                do {
                    self.onEvent("Connected to \(self.tagDescription(tagBox.value)) tag")
                    sessionBox.value.alertMessage = self.options.receivesFullHistory
                    ? self.progressMessage(currentCount: 0, totalCount: 10)
                    : String(localized: "Reading latest NovoPen doses")
                    let transceiver = try CoreNFCISO7816Transceiver(
                        tag: tagBox.value,
                        logsTraffic: !self.options.receivesFullHistory,
                        onEvent: self.onEvent
                    )
                    
                    let reading = try await NovoPenSession(
                        options: self.options,
                        onProgress: { currentCount, totalCount in
                            Task { @MainActor in
                                guard !self.isCompleted else {
                                    return
                                }
                                
                                sessionBox.value.alertMessage = self.progressMessage(
                                    currentCount: currentCount,
                                    totalCount: totalCount
                                )
                            }
                        },
                        onEvent: self.onEvent
                    ) .readPen(using: transceiver)
                    self.finish(with: .success(reading), session: sessionBox.value)
                } catch {
                    self.onEvent("Reader error [\(String(reflecting: type(of: error)))]: \(error.localizedDescription)")
                    self.finish(with: .failure(error), session: sessionBox.value)
                }
            }
        }
    }
    
    private func finish(with result: Result<PenReading, Error>, session: NFCTagReaderSession) {
        guard !isCompleted, let continuation else {
            return
        }
        
        isCompleted = true
        self.continuation = nil
        self.session = nil
        
        switch result {
        case let .success(reading):
            session.alertMessage = String(localized: "NovoPen data loaded")
            session.invalidate()
            continuation.resume(returning: reading)
            
        case let .failure(error):
            session.invalidate(errorMessage: error.localizedDescription)
            continuation.resume(throwing: error)
        }
    }
    
    private func tagDescription(_ tag: NFCTag) -> String {
        switch tag {
        case .feliCa: "FeliCa"
        case .iso7816: "ISO7816"
        case .iso15693: "ISO15693"
        case .miFare: "MiFare"
        @unknown default: "Unknown"
        }
    }
    
    private func progressMessage(currentCount: Int, totalCount: Int?) -> String {
        guard let totalCount, totalCount > 0 else {
            return progressCircles(filledCount: 0)
        }
        
        let progress = Double(currentCount) / Double(totalCount)
        let filledCount = min(Int(progress * 10), 10)
        return progressCircles(filledCount: filledCount)
    }
    
    private func progressCircles(filledCount: Int) -> String {
        String(repeating: "🟢", count: filledCount) + String(repeating: "⚪️", count: max(10 - filledCount, 0))
    }
}
