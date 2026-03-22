import Foundation

struct DoseEntry: Identifiable, Hashable {
    let id = UUID()
    let timestamp: Date
    let rawUnits: Int
    
    var units: Double {
        Double(rawUnits) / 10
    }
}
