import Foundation

struct NovoPenReaderService {
    func readPen(
        using source: NovoPenReadSource,
        options: ReaderOptions,
        onEvent: @escaping @Sendable (String) -> Void = { _ in }
    ) async throws -> PenReading {
        switch source {
        case .liveNFC:
            return try await CoreNFCPenScanner(options: options, onEvent: onEvent).readPen()
            
        case .sampleTrace:
            onEvent("Loading bundled trace")
            let responses = try HexTraceLoader().loadResponses(from: "nvp_datatest", in: .main)
            onEvent("Loaded \(responses.count) bundled response packets")
            let transceiver = MockTraceTransceiver(responses: responses, onEvent: onEvent)
            return try await NovoPenSession(options: options, onEvent: onEvent).readPen(using: transceiver)
        }
    }
}
