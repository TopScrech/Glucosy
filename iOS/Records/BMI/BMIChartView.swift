import SwiftUI
import Charts

struct BMIChartView: View {
    @State private var range: MeasurementChartRange = .month
    
    private let records: [BMI]
    
    init(records: [BMI]) {
        self.records = records
    }
    
    var body: some View {
        let now = Date.now
        let points = records.chartPoints(in: range, aggregation: .average, endingAt: now)
        let latestRecord = records.latestRecord(in: range, endingAt: now)
        let interval = range.interval(endingAt: now)
        
        MeasurementChartCard(
            value: summaryValue(for: latestRecord),
            tint: .mint,
            range: $range
        ) {
            if points.isEmpty {
                ContentUnavailableView("No Data", systemImage: "figure")
            } else {
                Chart(points) {
                    AreaMark(
                        x: .value("Date", $0.date),
                        y: .value("BMI", $0.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.mint.opacity(0.24), .mint.opacity(0.04)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    LineMark(
                        x: .value("Date", $0.date),
                        y: .value("BMI", $0.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.mint)
                    .lineStyle(.init(lineWidth: 3))
                    
                    PointMark(
                        x: .value("Date", $0.date),
                        y: .value("BMI", $0.value)
                    )
                    .foregroundStyle(.mint)
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
    
    private func summaryValue(for latestRecord: BMI?) -> String {
        guard let latestRecord else {
            return "No Data"
        }
        
        return latestRecord.value.formatted(.number.precision(.fractionLength(1)))
    }
}
