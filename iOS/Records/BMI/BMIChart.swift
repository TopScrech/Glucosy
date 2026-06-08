import SwiftUI
import Charts

struct BMIChart: View {
    private let records: [BMI]
    
    init(_ records: [BMI]) {
        self.records = records
    }
    
    @State private var range: MeasurementChartRange = .month
    @State private var selectedPoint: MeasurementChartPoint?
    
    var body: some View {
        let now = Date.now
        let points = records.chartPoints(in: range, aggregation: .average, endingAt: now)
        let latestRecord = records.latestRecord(in: range, endingAt: now)
        let interval = range.interval(endingAt: now)
        let yDomain = yDomain(for: points)
        
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
                        yStart: .value("Minimum BMI", yDomain.lowerBound),
                        yEnd: .value("BMI", $0.value)
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
                .chartOverlay { proxy in
                    MeasurementChartLollipopOverlay(
                        proxy: proxy,
                        points: points,
                        selectedPoint: $selectedPoint,
                        tint: .mint,
                        value: lollipopValue
                    )
                }
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
                    AxisMarks(position: .trailing, values: .stride(by: 2))
                }
                .chartXScale(domain: interval.start...interval.end)
                .chartYScale(domain: yDomain)
                .onChange(of: range) { _, _ in
                    selectedPoint = nil
                }
            }
        }
    }
    
    private func yDomain(for points: [MeasurementChartPoint]) -> ClosedRange<Double> {
        let values = points.map(\.value)
        let lowerBound = ((values.min() ?? 0) / 2).rounded(.down) * 2
        var upperBound = ((values.max() ?? 0) / 2).rounded(.up) * 2
        
        if lowerBound == upperBound {
            upperBound += 2
        }
        
        return lowerBound...upperBound
    }
    
    private func summaryValue(for latestRecord: BMI?) -> String {
        guard let latestRecord else {
            return "No Data"
        }
        
        return Utils.formatTenths(latestRecord.value)
    }
    
    private func lollipopValue(for point: MeasurementChartPoint) -> String {
        Utils.formatTenths(point.value)
    }
}
