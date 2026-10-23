import Foundation
import HealthKit
import Testing
@testable import Records

struct HealthRecordDayTests {
    struct Record: HealthRecord {
        let id = UUID()
        let value = 1.0
        let sample: HKQuantitySample

        init(date: Date) {
            sample = HKQuantitySample(type: HKQuantityType(.dietaryCarbohydrates), quantity: HKQuantity(unit: .gram(), doubleValue: 1), start: date, end: date)
        }
    }

    @Test func groupedHistoryRetainsBackdatedAndSameTimeRecords() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let old = Record(date: now.addingTimeInterval(-172_800))
        let recent = Record(date: now)
        let sameTime = Record(date: now)
        let days = HealthRecordDay.group([old, recent, sameTime])
        #expect(days.count == 2)
        #expect(Set(days[0].records.map(\.id)) == [recent.id, sameTime.id])
        #expect(days[1].records.first?.id == old.id)
        #expect(days[0].date > days[1].date)
    }

    @Test func groupsByLocalCalendarDay() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 3600) ?? .gmt
        let midnightUTC = Date(timeIntervalSince1970: 1_699_920_000)
        let days = HealthRecordDay.group([
            Record(date: midnightUTC.addingTimeInterval(-1800)),
            Record(date: midnightUTC.addingTimeInterval(1800))
        ], calendar: calendar)
        #expect(days.count == 1)
        #expect(days[0].records[0].date > days[0].records[1].date)
    }

    @Test func emptyHistoryHasNoSections() {
        #expect(HealthRecordDay<Record>.group([]).isEmpty)
    }
}
