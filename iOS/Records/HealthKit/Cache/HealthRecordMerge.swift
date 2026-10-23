import Foundation

nonisolated enum HealthRecordMerge {
    static func preservingLocalChanges<Record>(
        from baseline: [Record],
        current: [Record],
        incoming: [Record],
        id: KeyPath<Record, UUID>,
        date: KeyPath<Record, Date>
    ) -> [Record] {
        let baselineIDs = Set(baseline.map { $0[keyPath: id] })
        let currentIDs = Set(current.map { $0[keyPath: id] })
        return merge(
            existing: incoming,
            incoming: current.filter { !baselineIDs.contains($0[keyPath: id]) },
            deletedIDs: baselineIDs.subtracting(currentIDs),
            id: id,
            date: date
        )
    }

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
