import ScrechKit

struct BodyWeightChartWidgetHeaderView: View {
    let entries: [WeightWidgetEntry]
    
    private var latestWeight: Double? {
        entries.last?.value
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text("Weight")
                .bold()
                .foregroundStyle(.indigo)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            
            Spacer(minLength: 4)
            
            if let latestWeight {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(latestWeight, format: .number.precision(.fractionLength(1)))
                        .title3(.bold)
                    
                    Text(" kg")
                        .footnote()
                        .secondary()
                }
                .lineLimit(1)
                .minimumScaleFactor(0.65)
            } else {
                Text("No Data")
                    .title3(.bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }
    
    private var accessibilityLabel: String {
        guard let latestWeight else {
            return "Body weight, no data"
        }
        
        return "Body weight \(latestWeight.formatted(.number.precision(.fractionLength(1)))) kilograms"
    }
}
