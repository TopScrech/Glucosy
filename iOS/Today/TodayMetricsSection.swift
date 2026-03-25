import SwiftUI

struct TodayMetricsSection: View {
    let metrics: [TodayMetricData]
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .title3(.semibold, design: .rounded)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(metrics) { metric in
                    NavigationLink(value: metric.destination) {
                        TodayMetricCard(metric: metric)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    TodayMetricsSection(metrics: [
        TodayMetricData(
            destination: .glucose,
            title: "Glucose",
            value: "120",
            unit: "mg/dL",
            icon: "drop",
            color: .red
        ),
        TodayMetricData(
            destination: .carbs,
            title: "Carbs",
            value: "45",
            unit: "g",
            icon: "fork.knife",
            color: .orange
        )
    ])
    .padding()
    .darkSchemePreferred()
}
