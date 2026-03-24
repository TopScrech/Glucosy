import Foundation

enum NovoPenError: LocalizedError {
    case nfcUnavailable,
         unsupportedTag,
         invalidApdu,
         invalidStatusWord(Int),
         missingConfiguration,
         missingSegmentInfo,
         missingSampleTrace,
         malformedPacket(String),
         transportEnded,
         cancelled
    
    var errorDescription: String? {
        switch self {
        case .nfcUnavailable:
            return String(localized: "NFC scanning is not available on this device")
            
        case .unsupportedTag:
            return String(localized: "This tag is not a supported NovoPen")
            
        case .invalidApdu:
            return String(localized: "The pen returned an invalid APDU")
            
        case let .invalidStatusWord(statusWord):
            let hexadecimal = String(statusWord, radix: 16, uppercase: true)
            let padded = String(repeating: "0", count: max(0, 4 - hexadecimal.count)) + hexadecimal
            return String(localized: "The pen returned status word \(padded)")
            
        case .missingConfiguration:
            return String(localized: "The pen did not return a configuration payload")
            
        case .missingSegmentInfo:
            return String(localized: "The pen did not return dose segment information")
            
        case .missingSampleTrace:
            return String(localized: "The bundled sample trace could not be loaded")
            
        case let .malformedPacket(message):
            return message
            
        case .transportEnded:
            return String(localized: "The sample trace ended before the read finished")
            
        case .cancelled:
            return String(localized: "The scan was cancelled")
        }
    }
}
