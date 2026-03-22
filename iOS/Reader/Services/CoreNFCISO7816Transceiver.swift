@preconcurrency import CoreNFC
import Foundation

final class CoreNFCISO7816Transceiver: NovoPenTransceiver {
    private enum Backend {
        case iso7816(any NFCISO7816Tag)
        case miFare(any NFCMiFareTag)
    }

    private let backend: Backend
    private let logsTraffic: Bool
    private let onEvent: @Sendable (String) -> Void

    var isApplicationPreselected: Bool {
        switch backend {
        case .iso7816:
            true
        case .miFare:
            false
        }
    }

    init(
        tag: NFCTag,
        logsTraffic: Bool = true,
        onEvent: @escaping @Sendable (String) -> Void = { _ in }
    ) throws {
        self.logsTraffic = logsTraffic
        self.onEvent = onEvent

        switch tag {
        case let .iso7816(tag):
            backend = .iso7816(tag)
            onEvent("Using ISO7816 backend id=\(tag.identifier.hexString) hist=\((tag.historicalBytes ?? Data()).hexString)")
            onEvent("Core NFC delivered ISO7816 tag with AID already selected")
        case let .miFare(tag):
            backend = .miFare(tag)
            onEvent("Using MiFare backend id=\(tag.identifier.hexString) family=\(String(describing: tag.mifareFamily))")
        default:
            throw NovoPenError.unsupportedTag
        }
    }

    func transceive(_ command: Data) async throws -> Data {
        if logsTraffic {
            onEvent("NFC TX \(command.hexString)")
        }

        guard let apdu = NFCISO7816APDU(data: command) else {
            onEvent("Failed to build APDU from command")
            throw NovoPenError.invalidApdu
        }

        let fullResponse: Data

        do {
            switch backend {
            case let .iso7816(tag):
                fullResponse = try await withCheckedThrowingContinuation { continuation in
                    tag.sendCommand(apdu: apdu) { result in
                        switch result {
                        case let .success(response):
                            var fullResponse = Data()
                            fullResponse.append(response.payload ?? Data())
                            fullResponse.append(response.statusWord1)
                            fullResponse.append(response.statusWord2)
                            continuation.resume(returning: fullResponse)
                        case let .failure(error):
                            continuation.resume(throwing: error)
                        }
                    }
                }
            case let .miFare(tag):
                fullResponse = try await withCheckedThrowingContinuation { continuation in
                    tag.sendMiFareISO7816Command(apdu) { result in
                        switch result {
                        case let .success(response):
                            var fullResponse = Data()
                            fullResponse.append(response.payload ?? Data())
                            fullResponse.append(response.statusWord1)
                            fullResponse.append(response.statusWord2)
                            continuation.resume(returning: fullResponse)
                        case let .failure(error):
                            continuation.resume(throwing: error)
                        }
                    }
                }
            }
        } catch {
            onEvent("NFC transport error [\(String(reflecting: type(of: error)))]: \(error.localizedDescription)")
            throw error
        }

        if logsTraffic {
            onEvent("NFC RX \(fullResponse.hexString)")
        }

        return fullResponse
    }
}
