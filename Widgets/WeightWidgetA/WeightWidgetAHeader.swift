import ScrechKit
import WidgetKit

struct WeightWidgetAHeader: View {
    @Environment(\.widgetFamily) private var widgetFamily
    
    let entry: SimpleEntry
    
    private var beginEntry: WeightWidgetEntry? {
        entry.weightEntries.first
    }
    
    private var latestEntry: WeightWidgetEntry? {
        entry.weightEntries.last
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading) {
                Text("Weight")
                    .caption()
                    .secondary()
                
                if widgetFamily == .systemMedium {
                    Text(weightRangeText)
                        .title3(.bold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                } else if let latestEntry {
                    (Text(latestEntry.value, format: .number.precision(.fractionLength(1))) + Text(" kg"))
                        .title3(.bold)
                } else {
                    Text("No Data")
                        .title(.bold)
                }
            }
            
            Spacer()
            
            if widgetFamily == .systemMedium {
                VStack(alignment: .leading, spacing: 0) {
                    Text(beginDateText + " -")
                    Text(latestDateText)
                }
                .caption2()
                .secondary()
                
            } else if let latestEntry {
                Text(latestEntry.date, format: .dateTime.month().day())
                    .caption2()
                    .secondary()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }
    
    private var weightRangeText: String {
        guard let beginEntry, let latestEntry else {
            return "No Data"
        }
        
        let beginWeight = beginEntry.value.formatted(.number.precision(.fractionLength(1)))
        let latestWeight = latestEntry.value.formatted(.number.precision(.fractionLength(1)))
        
        return "\(beginWeight) - \(latestWeight) kg"
    }
    
    private var beginDateText: String {
        guard let beginEntry else {
            return "--"
        }
        
        return beginEntry.date.formatted(.dateTime.month().day())
    }
    
    private var latestDateText: String {
        guard let latestEntry else {
            return "--"
        }
        
        return latestEntry.date.formatted(.dateTime.month().day())
    }
    
    private var accessibilityLabel: String {
        guard let latestEntry else {
            return "Weight, no data"
        }
        
        if widgetFamily == .systemMedium {
            return "Weight range \(weightRangeText), date range \(beginDateText) to \(latestDateText)"
        }
        
        return "Latest weight \(latestEntry.value.formatted(.number.precision(.fractionLength(1)))) kilograms"
    }
}
