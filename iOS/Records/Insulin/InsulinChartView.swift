import SwiftUI
import Charts

struct InsulinChartView: View {
    @State private var range: MeasurementChartRange = .month
    
    private let segmentSpacing = 0.3
    
    private let records: [Insulin]
    
    init(records: [Insulin]) {
        self.records = records
    }
    
    var body: some View {
        let now = Date.now
        let segments = chartSegments(endingAt: now)
        let interval = range.interval(endingAt: now)
        
        MeasurementChartCard(
            value: summaryValue(segments: segments, endingAt: now),
            tint: .purple,
            range: $range
        ) {
            if segments.isEmpty {
                ContentUnavailableView("No Data", systemImage: "syringe")
            } else {
                Chart(segments) {
                    BarMark(
                        x: .value("Date", $0.date),
                        yStart: .value("Insulin Start", $0.lowerBound),
                        yEnd: .value("Insulin End", $0.upperBound)
                    )
                    .foregroundStyle($0.color)
                }
                .chartLegend(.hidden)
                .chartXAxis {
                    AxisMarks(values: .stride(by: range.axisStrideComponent, count: range.axisStrideCount)) { value in
                        AxisGridLine()
                        
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(range.axisLabel(for: date))
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .trailing)
                }
                .chartXScale(domain: interval.start...interval.end)
            }
        }
    }
    
    private func summaryValue(segments: [InsulinChartSegment], endingAt now: Date) -> String {
        let totalsByDate = Dictionary(grouping: segments, by: \.date)
            .mapValues { $0.reduce(into: 0.0) { $0 += $1.value } }
        let totalInsulin = totalsByDate.values.reduce(into: 0.0) { $0 += $1 }
        
        guard !totalsByDate.isEmpty else {
            return "No Data"
        }
        
        let value = range.usesAverageAggregation
            ? totalInsulin / Double(range.dayCount(endingAt: now))
            : totalInsulin
        
        return "\(value.formatted(.number.precision(.fractionLength(0 ... 1)))) U"
    }
    
    private func chartSegments(endingAt now: Date) -> [InsulinChartSegment] {
        let filteredRecords = records.records(in: range, endingAt: now)
        let groupedRecords = Dictionary(grouping: filteredRecords) {
            range.bucketStart(for: $0.date)
        }
        let orderedTypes: [InsulinType] = [.basal, .bolus]
        
        return groupedRecords
            .keys
            .sorted()
            .flatMap { date -> [InsulinChartSegment] in
                let records = groupedRecords[date] ?? []
                var segments: [InsulinChartSegment] = []
                var currentY = 0.0
                
                for type in orderedTypes {
                    let typedRecords = records.filter { $0.type == type }
                    
                    guard !typedRecords.isEmpty else {
                        continue
                    }
                    
                    let total = typedRecords.reduce(into: 0.0) { partialResult, record in
                        partialResult += record.value
                    }
                    let value = total
                    let lowerBound = currentY + (segments.isEmpty ? 0 : segmentSpacing)
                    let upperBound = lowerBound + value
                    
                    segments.append(
                        InsulinChartSegment(
                            date: date,
                            type: type,
                            value: value,
                            lowerBound: lowerBound,
                            upperBound: upperBound
                        )
                    )
                    currentY = upperBound
                }
                
                return segments
            }
    }
}
