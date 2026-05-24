import ScrechKit

struct WeightWidgetEntryView: View {
    private let entry: SimpleEntry
    
    init(_ entry: SimpleEntry) {
        self.entry = entry
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            WeightWidgetHeaderView(entry: entry)
                .padding(.horizontal, 6)
                .padding(.top, 6)
            
            if entry.weightEntries.isEmpty {
                WeightWidgetEmptyView(errorDescription: entry.errorDescription)
            } else {
                WeightWidgetChartView(entries: entry.weightEntries)
                
                WeightWidgetStatsView(entries: entry.weightEntries)
                    .padding(.horizontal, 6)
                    .padding(.bottom, 5)
            }
        }
    }
}
