import ScrechKit
import WidgetKit

struct BodyWeightChartWidgetView: View {
    let entry: SimpleEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if entry.weightEntries.isEmpty {
                WeightWidgetEmptyView(errorDescription: entry.errorDescription)
            } else {
                BodyWeightChartWidgetHeaderView(entries: entry.weightEntries)
                
                BodyWeightChartView(entries: entry.weightEntries)
                
                BodyWeightChartDateRangeView(entries: entry.weightEntries)
            }
        }
    }
}
