import Foundation

struct InsulinChartPoint: Identifiable {
    let date: Date
    let type: InsulinType
    let value: Double

    var id: String {
        "\(date.timeIntervalSinceReferenceDate)-\(type.rawValue)"
    }

    var title: String {
        type.title
    }
}
