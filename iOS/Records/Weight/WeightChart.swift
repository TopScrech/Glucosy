import SwiftUI
import Charts

struct WeightChart: View {
    @State private var range: MeasurementChartRange = .month
    @State private var selectedPoint: MeasurementChartPoint?
    
    private let records: [Weight]
    
    init(_ records: [Weight]) {
        self.records = records
    }
    
    var body: some View {
        let now = Date.now
        let points = records.chartPoints(in: range, aggregation: .average, endingAt: now)
        let latestRecord = records.latestRecord(in: range, endingAt: now)
        let interval = range.interval(endingAt: now)
        let yDomain = yDomain(for: points)
        
        MeasurementChartCard(
            value: summaryValue(for: latestRecord),
            tint: .blue,
            range: $range
        ) {
            if points.isEmpty {
                ContentUnavailableView("No Data", systemImage: "scalemass")
            } else {
                Chart(points) {
                    AreaMark(
                        x: .value("Date", $0.date),
                        yStart: .value("Minimum Weight", yDomain.lowerBound),
                        yEnd: .value("Weight", $0.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue.opacity(0.24), .blue.opacity(0.04)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    LineMark(
                        x: .value("Date", $0.date),
                        y: .value("Weight", $0.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.blue)
                    .lineStyle(.init(lineWidth: 3))
                    
                    PointMark(
                        x: .value("Date", $0.date),
                        y: .value("Weight", $0.value)
                    )
                    .foregroundStyle(.blue)
                }
                .chartLegend(.hidden)
                .chartOverlay { proxy in
                    MeasurementChartLollipopOverlay(
                        proxy: proxy,
                        points: points,
                        selectedPoint: $selectedPoint,
                        tint: .blue,
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
                    AxisMarks(position: .trailing, values: .stride(by: 5))
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
        let lowerBound = ((values.min() ?? 0) / 5).rounded(.down) * 5
        var upperBound = ((values.max() ?? 0) / 5).rounded(.up) * 5
        
        if lowerBound == upperBound {
            upperBound += 5
        }
        
        return lowerBound...upperBound
    }
    
    private func summaryValue(for latestRecord: Weight?) -> String {
        guard let latestRecord else {
            return "No Data"
        }
        
        return "\(Utils.formatTenths(latestRecord.value)) kg"
    }
    
    private func lollipopValue(for point: MeasurementChartPoint) -> String {
        "\(Utils.formatTenths(point.value)) kg"
    }
}
