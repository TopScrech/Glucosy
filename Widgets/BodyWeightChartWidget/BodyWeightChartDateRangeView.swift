import ScrechKit

struct BodyWeightChartDateRangeView: View {
    let entries: [WeightWidgetEntry]
    
    private var firstDate: Date? {
        entries.first?.date
    }
    
    private var lastDate: Date? {
        entries.last?.date
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            if let firstDate {
                Text(firstDate, format: .dateTime.month().day())
            }
            
            Spacer(minLength: 4)
            
            if let lastDate {
                Text(lastDate, format: .dateTime.month().day())
            }
        }
        .caption2()
        .secondary()
        .lineLimit(1)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }
    
    private var accessibilityLabel: String {
        guard let firstDate, let lastDate else {
            return "No date range"
        }
        
        return "Date range \(firstDate.formatted(.dateTime.month().day())) to \(lastDate.formatted(.dateTime.month().day()))"
    }
}
