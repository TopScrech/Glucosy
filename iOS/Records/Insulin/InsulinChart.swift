import SwiftUI
import Charts

struct InsulinChart: View {
    private let records: [Insulin]
    
    init(_ records: [Insulin]) {
        self.records = records
    }
    
    @State private var range: MeasurementChartRange = .month
    
    private let chartColors: KeyValuePairs<String, Color> = [
        InsulinType.basal.title: Color(red: 0.0, green: 0.36, blue: 0.88),
        InsulinType.bolus.title: .blue
    ]
    
    var body: some View {
        let now = Date.now
        let filteredRecords = records.records(in: range, endingAt: now)
        let points = chartPoints(from: filteredRecords)
        let interval = range.interval(endingAt: now)
        
        MeasurementChartCard(
            title: "Basal and Bolus",
            value: summaryValue(totalInsulin: totalInsulin(in: filteredRecords), endingAt: now),
            tint: .purple,
            range: $range
        ) {
            if points.isEmpty {
                ContentUnavailableView("No Data", systemImage: "syringe")
            } else {
                Chart(points) {
                    BarMark(
                        x: .value("Date", $0.date),
                        y: .value("Insulin", $0.value)
                    )
                    .foregroundStyle(by: .value("Type", $0.title))
                    .position(by: .value("Type", $0.title))
                }
                .chartLegend(position: .top)
                .chartForegroundStyleScale(chartColors)
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
    
    private func summaryValue(totalInsulin: Double, endingAt now: Date) -> String {
        guard totalInsulin > 0 else {
            return "No Data"
        }
        
        let value = range.usesAverageAggregation
        ? totalInsulin / Double(range.dayCount(endingAt: now))
        : totalInsulin
        
        return "\(value.formatted(.number.precision(.fractionLength(0 ... 1)))) U"
    }
    
    private func totalInsulin(in records: [Insulin]) -> Double {
        records.reduce(into: 0.0) { partialResult, record in
            partialResult += record.value
        }
    }
    
    private func chartPoints(from records: [Insulin]) -> [InsulinChartPoint] {
        let groupedRecords = Dictionary(grouping: records) {
            range.bucketStart(for: $0.date)
        }
        
        let orderedTypes: [InsulinType] = [.basal, .bolus]
        
        return groupedRecords
            .keys
            .sorted()
            .flatMap { date -> [InsulinChartPoint] in
                let records = groupedRecords[date] ?? []
                
                return orderedTypes.compactMap { type in
                    let typedRecords = records.filter { $0.type == type }
                    
                    let total = typedRecords.reduce(into: 0.0) { partialResult, record in
                        partialResult += record.value
                    }
                    
                    guard total > 0 else {
                        return nil
                    }
                    
                    return InsulinChartPoint(date: date, type: type, value: total)
                }
            }
    }
}
