import ScrechKit

struct GlucoseCard: View {
    @EnvironmentObject private var store: ValueStore
    
    private let record: Glucose
    private let onDelete: (() -> Void)?
    
    init(
        _ record: Glucose,
        onDelete: (() -> Void)? = nil
    ) {
        self.record = record
        self.onDelete = onDelete
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
            if let onDelete {
                Section {
                    Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
                }
            }
        }
    }
}

//#Preview {
//    GlucoseCard()
//    .darkSchemePreferred()
//}
