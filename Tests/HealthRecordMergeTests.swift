import Foundation

@main
struct HealthRecordMergeTests {
    struct Record: Equatable {
        let id: UUID
        let date: Date
        let value: Double
    }

    static func main() {
        let old = Record(id: UUID(), date: Date(timeIntervalSince1970: 10), value: 1)
        let recent = Record(id: UUID(), date: Date(timeIntervalSince1970: 100), value: 2)
        let updated = Record(id: recent.id, date: recent.date, value: 3)
        let sameDate = Record(id: UUID(), date: recent.date, value: recent.value)
        let merge = HealthRecordMerge.merge(existing: [old, recent], incoming: [updated, updated, sameDate], id: \.id, date: \.date)
        precondition(merge.count == 3, "Repeated UUIDs must collapse, but distinct records at the same time must survive")
        precondition(merge.first { $0.id == recent.id }?.value == 3)
        let repeated = HealthRecordMerge.merge(existing: merge, incoming: [updated, sameDate], id: \.id, date: \.date)
        precondition(Set(repeated.map(\.id)) == Set(merge.map(\.id)))
        let deleted = HealthRecordMerge.merge(existing: repeated, incoming: [], deletedIDs: [old.id], id: \.id, date: \.date)
        precondition(!deleted.contains { $0.id == old.id }, "Deletions outside the recent window must remove cached records")
        let refreshed = HealthRecordMerge.merge(existing: merge, incoming: [], replacing: DateInterval(start: Date(timeIntervalSince1970: 50), end: Date(timeIntervalSince1970: 100)), id: \.id, date: \.date)
        precondition(refreshed == [old], "An empty recent refresh must clear deleted records and preserve older history")
        let boundary = HealthRecordMerge.merge(existing: merge, incoming: [updated], replacing: DateInterval(start: recent.date, end: recent.date), id: \.id, date: \.date)
        precondition(boundary.count == 2)
        let fullRefresh = HealthRecordMerge.merge(existing: [], incoming: [updated, updated], id: \.id, date: \.date)
        precondition(fullRefresh == [updated], "Full history must replace the cache and exclude deleted older records")
        let startupCutoff = Date(timeIntervalSince1970: 200)
        let olderMeasurements = HealthStartupRecords.select(from: [recent, old], since: startupCutoff, date: \.date)
        precondition(olderMeasurements == [recent], "Weight and BMI must restore the latest saved measurement when nothing was recorded today")
        let unorderedMeasurements = HealthStartupRecords.select(from: [old, updated], since: old.date, date: \.date)
        precondition(unorderedMeasurements.first == updated, "A backdated write must not replace the latest measurement")
        let afterDeletion = HealthStartupRecords.select(from: [old], since: startupCutoff, date: \.date)
        precondition(afterDeletion == [old], "Deleting the latest measurement must expose the previous saved value")
        let emptyStartup = HealthStartupRecords.select(from: [Record](), since: startupCutoff, date: \.date)
        precondition(emptyStartup.isEmpty, "Deleting all measurements must clear the saved value")
        print("Health record merge and startup tests passed")
    }
}
