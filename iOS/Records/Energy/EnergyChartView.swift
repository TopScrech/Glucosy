import SwiftUI
import Charts

struct EnergyChartView: View {
    let kind: EnergyKind
    let days: [EnergyDay]
    @State private var range: MeasurementChartRange = .month

    var body: some View {
        let data = EnergyChartData(days: days, range: range, now: .now)
        let interval = range.interval(endingAt: data.now)

        MeasurementChartCard(title: String(localized: "Daily Average"), value: data.summary, tint: kind.color, range: $range) {
            if data.points.isEmpty {
                ContentUnavailableView("No Data", systemImage: kind.icon)
            } else {
                Chart(data.points) {
                    BarMark(x: .value("Date", $0.date), y: .value("kcal", $0.value))
                        .foregroundStyle(kind.color.gradient)
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
                .chartYAxis { AxisMarks(position: .trailing) }
                .chartXScale(domain: interval.start...interval.end)
            }
        }
    }
}
