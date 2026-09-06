import Foundation

struct EnergyChartData {
    let days: [EnergyDay]
    let range: MeasurementChartRange
    let now: Date

    var filteredDays: [EnergyDay] {
        let interval = range.interval(endingAt: now)
        return days.filter { $0.date >= interval.start && $0.date <= interval.end }
    }

    var points: [MeasurementChartPoint] {
        Dictionary(grouping: filteredDays) { range.bucketStart(for: $0.date) }
            .map { date, days in
                MeasurementChartPoint(date: date, value: days.reduce(0) { $0 + $1.value })
            }
            .sorted { $0.date < $1.date }
    }

    var summary: String {
        guard !filteredDays.isEmpty else { return String(localized: "No Data") }
        let total = filteredDays.reduce(0) { $0 + $1.value }
        let average = total / Double(range.dayCount(endingAt: now))
        return "\(average.formatted(.number.precision(.fractionLength(0)))) \(String(localized: "kcal"))"
    }
}
