import Foundation

extension PenReading {
    var modelDisplayValue: String {
        model.isEmpty ? String(localized: "Unavailable") : model
    }
    
    var serialDisplayValue: String {
        serial.isEmpty ? String(localized: "Unavailable") : serial
    }
    
    var penStartedAtDisplayValue: Date? {
        penTimeSeconds > 0 ? penStartedAt : nil
    }
}
