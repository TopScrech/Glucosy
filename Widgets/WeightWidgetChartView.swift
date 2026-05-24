import Charts
import ScrechKit

struct WeightWidgetChartView: View {
    let entries: [WeightWidgetEntry]
    
    private var yDomain: ClosedRange<Double> {
        let values = entries.map(\.value)
        guard let minimum = values.min(), let maximum = values.max() else {
            return 0...1
        }
        
        guard minimum != maximum else {
            return (minimum - 1)...(maximum + 1)
        }
        
        let padding = (maximum - minimum) * 0.2
        return (minimum - padding)...(maximum + padding)
    }
    
    var body: some View {
        Chart(entries) {
            LineMark(
                x: .value("Date", $0.date),
                y: .value("Weight", $0.value)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(.cyan)
            .lineStyle(.init(lineWidth: 3, lineCap: .round, lineJoin: .round))
            
            PointMark(
                x: .value("Date", $0.date),
                y: .value("Weight", $0.value)
            )
            .symbolSize(28)
            .foregroundStyle(.cyan)
        }
        .chartLegend(.hidden)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(domain: yDomain)
        .accessibilityLabel("Last 10 weight entries")
    }
}
