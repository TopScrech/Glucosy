import Foundation
import SwiftData

@Model
final class SavedPen {
    var createdAt = Date()
    var insulinType: InsulinType = InsulinType.bolus
    var model = ""
    var serial = ""
    
    init(
        model: String,
        serial: String,
        insulinType: InsulinType
    ) {
        self.model = model
        self.serial = serial
        self.insulinType = insulinType
    }
}

extension SavedPen {
    var title: String {
        if !model.isEmpty {
            return model
        }
        
        if !serial.isEmpty {
            return serial
        }
        
        return String(localized: "Unavailable")
    }
    
    func matches(_ reading: PenReading) -> Bool {
        model == reading.model && serial == reading.serial
    }
}
