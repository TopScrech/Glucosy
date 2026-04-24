import ScrechKit

struct GlucoseRecordCard: View {
    @Environment(HealthKit.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    private let record: Glucose
    
    init(_ record: Glucose) {
        self.record = record
    }
    
    var body: some View {
        HStack {
            SourceImage(record.sourceID)
            
            VStack(alignment: .leading) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(record.formattedValue(in: store.glucoseUnit))
                        .title3(.semibold, design: .rounded)
                    
                    Text(store.glucoseUnit.title)
                        .caption()
                        .secondary()
                }
                
                if store.debugMode {
                    SourceName(record.source)
                }
            }
            
            Spacer()
            
            Text(record.date, format: .dateTime.hour().minute())
                .secondary()
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button("Delete", systemImage: "trash", role: .destructive) {
                vm.deleteGlucose(record)
            }
        }
        .contextMenu {
#if DEBUG
            Button {
                UIPasteboard.general.string = record.source
            } label: {
                Text("Copy Source")
                
                Text(record.source)
                
                Image(systemName: "doc.on.doc")
            }
#endif
            Section {
                Button("Delete", systemImage: "trash", role: .destructive) {
                    vm.deleteGlucose(record)
                }
            }
        }
    }
}
