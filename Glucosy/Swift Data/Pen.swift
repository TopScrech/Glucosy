import Foundation
import SwiftData

@Model
final class Pen {
    var name = ""
    var type = InsulinType.bolus
    var expiration = Date()
    
    init(name: String, type: InsulinType, expiration: Date) {
        self.name = name
        self.type = type
        self.expiration = expiration
    }
}
