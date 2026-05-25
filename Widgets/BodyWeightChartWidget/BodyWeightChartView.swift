import Charts
import ScrechKit

struct BodyWeightChartView: View {
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
            AreaMark(
                x: .value("Date", $0.date),
                yStart: .value("Minimum Weight", yDomain.lowerBound),
                yEnd: .value("Weight", $0.value)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(areaGradient)
            
            LineMark(
                x: .value("Date", $0.date),
                y: .value("Weight", $0.value)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(.indigo)
            .lineStyle(.init(lineWidth: 3, lineCap: .round, lineJoin: .round))
        }
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) {
                AxisGridLine()
            }
        }
        .chartYScale(domain: yDomain)
        .chartPlotStyle {
            $0.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .accessibilityLabel("Recent body weight chart")
    }
    
    private var areaGradient: LinearGradient {
        LinearGradient(
            colors: [
                .indigo.opacity(0.24),
                .indigo.opacity(0.02)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
