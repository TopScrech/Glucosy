import ScrechKit

struct WeightWidgetStatsView: View {
    let entries: [WeightWidgetEntry]
    
    private var beginEntry: WeightWidgetEntry? {
        entries.first
    }
    
    private var weightChange: Double? {
        guard let beginEntry, let latestEntry = entries.last else {
            return nil
        }
        
        return latestEntry.value - beginEntry.value
    }
    
    var body: some View {
        WeightWidgetChangeView(value: changeText)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityLabel)
    }
    
    private var changeText: String {
        guard let weightChange else {
            return "--"
        }
        
        let prefix = weightChange > 0 ? "+" : ""
        return "\(prefix)\(weightChange.formatted(.number.precision(.fractionLength(1)))) kg"
    }
    
    private var accessibilityLabel: String {
        "Weight change \(changeText)"
    }
}
