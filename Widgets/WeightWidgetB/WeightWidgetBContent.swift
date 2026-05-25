import ScrechKit
import WidgetKit

struct WeightWidgetBContent: View {
    @Environment(\.widgetFamily) private var widgetFamily
    
    let entry: SimpleEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            if entry.weightEntries.isEmpty {
                WeightWidgetEmpty(errorDescription: entry.errorDescription)
            } else {
                WeightWidgetBHeader(entries: entry.weightEntries)
                
                WeightWidgetBChart(entries: entry.weightEntries)
                
                WeightWidgetBDateRange(entries: entry.weightEntries)
            }
        }
    }
    
    private var spacing: CGFloat {
        widgetFamily == .systemMedium ? 8 : 6
    }
}
