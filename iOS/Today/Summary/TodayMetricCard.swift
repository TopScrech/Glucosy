import ScrechKit

struct TodayMetricCard: View {
    let metric: TodayMetricData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: metric.icon)
                    .foregroundStyle(metric.color)
                    .title3()
                
                Text(metric.title)
                    .caption()
                    .secondary()
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(metric.value)
                    .title2(.semibold, design: .rounded)
                    .monospacedDigit()
                
                if let unit = metric.unit {
                    Text(unit)
                        .caption2()
                        .secondary()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
    }
}

#Preview {
    TodayMetricCard(
        metric: TodayMetricData(
            destination: .glucose,
            title: "Glucose",
            value: "118",
            unit: "mg/dL",
            icon: "drop",
            color: .red
        )
    )
    .padding()
    .darkSchemePreferred()
}
