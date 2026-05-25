import ScrechKit

struct WeightWidgetAContent: View {
    private let entry: SimpleEntry
    
    init(_ entry: SimpleEntry) {
        self.entry = entry
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            WeightWidgetAHeader(entry: entry)
                .padding(.horizontal, 6)
                .padding(.top, 6)
            
            if entry.weightEntries.isEmpty {
                WeightWidgetEmpty(errorDescription: entry.errorDescription)
            } else {
                WeightWidgetAChart(entries: entry.weightEntries)
                
                WeightWidgetAStats(entries: entry.weightEntries)
                    .padding(.horizontal, 6)
                    .padding(.bottom, 5)
            }
        }
    }
}
