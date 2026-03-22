import Foundation

protocol NovoPenTransceiver {
    var isApplicationPreselected: Bool { get }
    
    func transceive(_ command: Data) async throws -> Data
}

extension NovoPenTransceiver {
    var isApplicationPreselected: Bool {
        false
    }
}
