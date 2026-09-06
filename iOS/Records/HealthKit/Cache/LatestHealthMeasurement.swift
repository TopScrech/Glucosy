import Foundation

nonisolated struct LatestHealthMeasurement: Codable, Equatable {
    let id: UUID
    let date: Date
    let value: Double
}
