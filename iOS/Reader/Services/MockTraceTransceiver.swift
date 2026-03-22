import Foundation

final class MockTraceTransceiver: NovoPenTransceiver {
    private let onEvent: @Sendable (String) -> Void
    private var responses: [Data]
    private var index = 0
    
    init(
        responses: [Data],
        onEvent: @escaping @Sendable (String) -> Void = { _ in }
    ) {
        self.onEvent = onEvent
        self.responses = responses
    }
    
    func transceive(_ command: Data) async throws -> Data {
        guard index < responses.count else {
            onEvent("TRACE end of sample at packet \(index + 1)")
            throw NovoPenError.transportEnded
        }
        
        let packetNumber = index + 1
        let response = responses[index]
        onEvent("TRACE TX #\(packetNumber) \(command.hexString)")
        onEvent("TRACE RX #\(packetNumber) \(response.hexString)")
        index += 1
        return response
    }
}
