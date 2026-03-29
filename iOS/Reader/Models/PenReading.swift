import Foundation

struct PenReading: Hashable, Identifiable {
    let model: String
    let serial: String
    let capturedAt: Date
    let penTimeSeconds: Int
    let doses: [DoseEntry]
    
    var id: String {
        "\(model)|\(serial)|\(capturedAt.timeIntervalSinceReferenceDate)"
    }
    
    var penStartedAt: Date {
        capturedAt.addingTimeInterval(-TimeInterval(penTimeSeconds))
    }
}
