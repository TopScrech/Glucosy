import Foundation

nonisolated enum HealthStartupRecords {
    static func select<Record>(from records: [Record], since cutoff: Date, date: KeyPath<Record, Date>) -> [Record] {
        let sorted = records.sorted { $0[keyPath: date] > $1[keyPath: date] }
        guard let latest = sorted.first else { return [] }
        let recent = sorted.filter { $0[keyPath: date] >= cutoff }
        // Always retain the latest measurement, even when the entire history predates the cutoff
        return recent.isEmpty ? [latest] : recent
    }
}
