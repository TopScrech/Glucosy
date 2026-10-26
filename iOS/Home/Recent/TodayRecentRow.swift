import ScrechKit

struct TodayRecentRow: View {
    let title: LocalizedStringKey
    let value: String?
    let unit: String?
    let date: Date?
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.15), in: .circle)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .title3(.semibold, design: .rounded)
                
                if let date {
                    TimelineView(.periodic(from: date, by: 60)) { context in
                        let minutesAgo = max(0, Int(context.date.timeIntervalSince(date) / 60))

                        Text("\(minutesAgo) min ago")
                            .caption()
                            .secondary()
                    }
                } else {
                    Text("No entries yet")
                        .caption()
                        .secondary()
                }
            }
            
            Spacer()
            
            if let value {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .title3(.semibold, design: .rounded)
                        .monospacedDigit()
                    
                    if let unit {
                        Text(unit)
                            .caption2()
                            .secondary()
                    }
                }
            } else {
                Text("-")
                    .secondary()
            }
        }
        .padding(12)
        .background(.thinMaterial, in: .rect(cornerRadius: 16))
    }
}

#Preview {
    TodayRecentRow(
        title: "Blood Glucose",
        value: "92-118",
        unit: "mg/dL",
        date: Date(),
        icon: "drop",
        color: .red
    )
    .padding()
    .darkSchemePreferred()
}
