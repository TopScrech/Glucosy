import Foundation
import SwiftData

@Model
final class SavedPen {
    var createdAt = Date()
    var customName = ""
    var insulinType: InsulinType = InsulinType.bolus
    var model = ""
    var serial = ""
    
    init(
        model: String,
        serial: String,
        customName: String = "",
        insulinType: InsulinType
    ) {
        self.model = model
        self.serial = serial
        self.customName = customName
        self.insulinType = insulinType
    }
}

extension SavedPen {
    var title: String {
        if !customName.isEmpty {
            return customName
        }
        
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
