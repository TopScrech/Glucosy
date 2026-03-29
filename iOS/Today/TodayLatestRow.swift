import SwiftUI

struct TodayLatestRow: View {
    let title: String
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
                    Text(date, format: .dateTime.month().day().hour().minute())
                        .caption()
                        .secondary()
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
    TodayLatestRow(
        title: "Blood Glucose",
        value: "118",
        unit: "mg/dL",
        date: Date(),
        icon: "drop",
        color: .red
    )
    .padding()
    .darkSchemePreferred()
}
