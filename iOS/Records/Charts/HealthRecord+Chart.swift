import Foundation

extension Sequence where Element: HealthRecord {
    func records(
        in range: MeasurementChartRange,
        endingAt now: Date = .now,
        calendar: Calendar = .current
    ) -> [Element] {
        let interval = range.interval(endingAt: now, calendar: calendar)
        
        return self
            .filter { $0.date >= interval.start && $0.date <= interval.end }
            .sorted { $0.date < $1.date }
    }
    
    func latestRecord(
        in range: MeasurementChartRange,
        endingAt now: Date = .now,
        calendar: Calendar = .current
    ) -> Element? {
        records(in: range, endingAt: now, calendar: calendar).last
    }
    
    func chartPoints(
        in range: MeasurementChartRange,
        aggregation: MeasurementChartAggregation,
        endingAt now: Date = .now,
        calendar: Calendar = .current
    ) -> [MeasurementChartPoint] {
        let groupedRecords = Dictionary(grouping: records(in: range, endingAt: now, calendar: calendar)) {
            range.bucketStart(for: $0.date, calendar: calendar)
        }
        
        return groupedRecords
            .map { date, records in
                let total = records.reduce(into: 0.0) { partialResult, record in
                    partialResult += record.value
                }
                
                let value = switch aggregation {
                case .average:
                    total / Double(records.count)
                    
                case .sum:
                    total
                }
                
                return MeasurementChartPoint(date: date, value: value)
            }
            .sorted { $0.date < $1.date }
    }
}
