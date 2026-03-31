import ScrechKit

struct WatchRecordRow: View {
    let entry: WatchRecordEntry
    
    var body: some View {
        HStack {
            Image(systemName: entry.systemImage)
                .foregroundStyle(entry.tint)
                .title3()
            
            VStack(alignment: .leading) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(entry.valueText)
                        .title3(.semibold, design: .rounded)
                    
                    Text(entry.unitText)
                        .secondary()
                }
                
                if let detailText = entry.detailText {
                    Text(detailText)
                        .secondary()
                }
            }
            
            Spacer()
            
            Text(entry.timestamp, format: .dateTime.hour().minute())
                .secondary()
        }
    }
}
