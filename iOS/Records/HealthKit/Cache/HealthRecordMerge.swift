import Foundation

nonisolated enum HealthRecordMerge {
    static func merge<Record>(
        existing: [Record],
        incoming: [Record],
        deletedIDs: Set<UUID> = [],
        replacing interval: DateInterval? = nil,
        id: KeyPath<Record, UUID>,
        date: KeyPath<Record, Date>
    ) -> [Record] {
        var byID: [UUID: Record] = [:]
        for record in existing {
            guard !deletedIDs.contains(record[keyPath: id]) else { continue }
            if let interval, interval.contains(record[keyPath: date]) { continue }
            byID[record[keyPath: id]] = record
        }
        for record in incoming where !deletedIDs.contains(record[keyPath: id]) {
            byID[record[keyPath: id]] = record
        }
        return byID.values.sorted { $0[keyPath: date] > $1[keyPath: date] }
    }
}
