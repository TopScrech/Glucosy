import Foundation

struct PenReading: Hashable {
    let model: String
    let serial: String
    let capturedAt: Date
    let penTimeSeconds: Int
    let doses: [DoseEntry]
    
    var penStartedAt: Date {
        capturedAt.addingTimeInterval(-TimeInterval(penTimeSeconds))
    }
}
