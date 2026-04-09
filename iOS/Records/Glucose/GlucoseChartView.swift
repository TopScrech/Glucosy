import SwiftUI
import Charts

struct GlucoseChartView: View {
    @EnvironmentObject private var store: ValueStore
    
    private let records: [Glucose]
    
    init(records: [Glucose]) {
        self.records = records
    }
    
    @State private var range: MeasurementChartRange = .month
    
    var body: some View {
        let now = Date.now
        let filteredRecords = records.records(in: range, endingAt: now)
        let rawPoints = records.chartPoints(in: range, aggregation: .average, endingAt: now)
        
        let points = rawPoints.map {
            MeasurementChartPoint(
                date: $0.date,
                value: store.glucoseUnit.displayValue(fromMilligramsPerDeciliter: $0.value)
            )
        }
        
        let interval = range.interval(endingAt: now)
        
        MeasurementChartCard(
            value: rangeTitle(for: filteredRecords) ?? "No Data",
            tint: .red,
            range: $range
        ) {
            if points.isEmpty {
                ContentUnavailableView("No Data", systemImage: "waveform.path.ecg")
            } else {
                Chart(points) {
                    AreaMark(
                        x: .value("Date", $0.date),
                        y: .value("Glucose", $0.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red.opacity(0.24), .red.opacity(0.04)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    LineMark(
                        x: .value("Date", $0.date),
                        y: .value("Glucose", $0.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.red)
                    .lineStyle(.init(lineWidth: 3))
                    
                    PointMark(
                        x: .value("Date", $0.date),
                        y: .value("Glucose", $0.value)
                    )
                    .foregroundStyle(.red)
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
    
    private func rangeTitle(for records: [Glucose]) -> String? {
        guard
            let minimum = records.min(by: { $0.value < $1.value }),
            let maximum = records.max(by: { $0.value < $1.value })
        else {
            return nil
        }
        
        let minimumValue = minimum.formattedValue(in: store.glucoseUnit)
        let maximumValue = maximum.formattedValue(in: store.glucoseUnit)
        
        return "\(minimumValue)-\(maximumValue) \(store.glucoseUnit.title)"
    }
}
