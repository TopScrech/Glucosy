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
                    GeometryReader { geometry in
                        ZStack(alignment: .topLeading) {
                            if let selectedPoint,
                               let positionX = proxy.position(forX: selectedPoint.date),
                               let positionY = proxy.position(forY: selectedPoint.value) {
                                let plotFrame = geometry[proxy.plotAreaFrame]
                                let lineX = plotFrame.origin.x + positionX
                                let pointY = plotFrame.origin.y + positionY
                                
                                WeightChartLollipop(
                                    point: selectedPoint,
                                    lineX: lineX,
                                    pointY: pointY,
                                    plotFrame: plotFrame,
                                    chartWidth: geometry.size.width
                                )
                                .allowsHitTesting(false)
                            }
                            
                            Rectangle()
                                .fill(.clear)
                                .contentShape(.rect)
                                .gesture(
                                    SpatialTapGesture()
                                        .onEnded {
                                            let point = findPoint(
                                                at: $0.location,
                                                proxy: proxy,
                                                geometry: geometry,
                                                points: points
                                            )
                                            
                                            if selectedPoint?.date == point?.date {
                                                selectedPoint = nil
                                            } else {
                                                selectedPoint = point
                                            }
                                        }
                                        .exclusively(
                                            before: DragGesture()
                                                .onChanged {
                                                    selectedPoint = findPoint(
                                                        at: $0.location,
                                                        proxy: proxy,
                                                        geometry: geometry,
                                                        points: points
                                                    )
                                                }
                                        )
                                )
                        }
                    }
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
    
    private func findPoint(
        at location: CGPoint,
        proxy: ChartProxy,
        geometry: GeometryProxy,
        points: [MeasurementChartPoint]
    ) -> MeasurementChartPoint? {
        let plotFrame = geometry[proxy.plotAreaFrame]
        let relativeX = location.x - plotFrame.origin.x
        
        guard let date = proxy.value(atX: relativeX) as Date? else {
            return nil
        }
        
        return points.min {
            abs($0.date.distance(to: date)) < abs($1.date.distance(to: date))
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
}
