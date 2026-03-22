import Foundation

extension PenReading {
    var modelDisplayValue: String {
        model.isEmpty ? "Unavailable" : model
    }
    
    var serialDisplayValue: String {
        serial.isEmpty ? "Unavailable" : serial
    }
    
    var penStartedAtDisplayValue: Date? {
        penTimeSeconds > 0 ? penStartedAt : nil
    }
}
