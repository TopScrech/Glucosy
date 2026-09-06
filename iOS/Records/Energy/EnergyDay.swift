import Foundation

nonisolated struct EnergyDay: Identifiable, Codable, Sendable {
    let date: Date
    let value: Double

    var id: Date { date }
}
