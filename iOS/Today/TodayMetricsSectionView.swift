import SwiftUI

struct TodayMetricData: Identifiable {
    let id: String
    let title: String
    let value: String
    let unit: String?
    let subtitle: String
    let icon: String
    let color: Color
}

struct TodayMetricsSectionView: View {
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
                    TodayMetricCardView(metric: metric)
                }
            }
        }
    }
}

#Preview {
    TodayMetricsSectionView(metrics: [
        TodayMetricData(
            id: "glucose",
            title: "Glucose",
            value: "120",
            unit: "mg/dL",
            subtitle: "Avg 128 mg/dL",
            icon: "drop",
            color: .red
        ),
        TodayMetricData(
            id: "carbs",
            title: "Carbs",
            value: "45",
            unit: "g",
            subtitle: "Last 8:30 AM",
            icon: "fork.knife",
            color: .orange
        )
    ])
    .padding()
    .darkSchemePreferred()
}
