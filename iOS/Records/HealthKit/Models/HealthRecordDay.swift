import Foundation

struct HealthRecordDay<Record: HealthRecord>: Identifiable {
    let date: Date
    var records: [Record]

    var id: Date { date }

    static func group(_ records: [Record], calendar: Calendar = .current) -> [Self] {
        Dictionary(grouping: records) { calendar.startOfDay(for: $0.date) }
            .map { Self(date: $0.key, records: $0.value.sorted { $0.date > $1.date }) }
            .sorted { $0.date > $1.date }
    }
}
