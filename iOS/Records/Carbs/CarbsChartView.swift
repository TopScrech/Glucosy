import Charts
import SwiftUI

struct CarbsChartView: View {
    @State private var range: MeasurementChartRange = .month
    
    private let records: [Carbs]
    
    init(records: [Carbs]) {
        self.records = records
    }
    
    var body: some View {
        let now = Date.now
        let filteredRecords = records.records(in: range, endingAt: now)
        let aggregation: MeasurementChartAggregation = range.usesAverageAggregation ? .average : .sum
        let points = records.chartPoints(in: range, aggregation: aggregation, endingAt: now)
        let interval = range.interval(endingAt: now)
        let totalCarbs = filteredRecords.reduce(into: 0.0) { partialResult, record in
            partialResult += record.value
        }
        let averageCarbs = filteredRecords.isEmpty ? 0 : totalCarbs / Double(filteredRecords.count)
        
        MeasurementChartCard(
            value: summaryValue(
                totalCarbs: totalCarbs,
                averageCarbs: averageCarbs,
                recordCount: filteredRecords.count
            ),
            tint: .orange,
            range: $range
        ) {
            if points.isEmpty {
                ContentUnavailableView("No Data", systemImage: "fork.knife")
            } else {
                Chart(points) {
                    BarMark(
                        x: .value("Date", $0.date),
                        y: .value("Carbs", $0.value)
                    )
                    .foregroundStyle(.orange.gradient)
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
                    AxisMarks(position: .leading)
                }
                .chartXScale(domain: interval.start...interval.end)
            }
        }
    }
    
    private func summaryValue(totalCarbs: Double, averageCarbs: Double, recordCount: Int) -> String {
        guard recordCount > 0 else {
            return "No Data"
        }
        
        let value = range.usesAverageAggregation ? averageCarbs : totalCarbs
        
        return "\(value.formatted(.number.precision(.fractionLength(0 ... 1)))) g"
    }
}
