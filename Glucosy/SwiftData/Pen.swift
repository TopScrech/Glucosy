import Foundation
import SwiftData

@Model
final class Pen {
    var name: String
    var type: InsulinType
    var expiration: Date
    
    init(name: String, type: InsulinType, expiration: Date) {
        self.name = name
        self.type = type
        self.expiration = expiration
    }
}
