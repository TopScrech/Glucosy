import Foundation

struct EnergyDay: Identifiable {
    let date: Date
    let value: Double

    var id: Date { date }
}
