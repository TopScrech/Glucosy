import ScrechKit
import HealthKit

struct WeightCard: View {
    @EnvironmentObject private var store: ValueStore
    
    private let record: Weight
    private let onDelete: (() -> Void)?
    
    init(
        _ record: Weight,
        onDelete: (() -> Void)? = nil
    ) {
        self.record = record
        self.onDelete = onDelete
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "scalemass")
                .foregroundStyle(.blue)
                .title3()
            
            VStack(alignment: .leading) {
                HStack(spacing: 5) {
                    Text(Utils.formatTenths(record.value))
                        .title3(.semibold, design: .rounded)
                    
                    Text("kg")
                        .secondary()
                }
                
                if store.debugMode {
                    SourceName(record.source)
                }
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                if store.debugMode {
                    SourceImage(record.sourceID)
                }
                
                Text(record.date, format: .dateTime.hour().minute())
                    .secondary()
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
            if let onDelete {
                Section {
                    Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
                }
            }
        }
    }
}

#Preview {
    List {
        WeightCard(
            Weight(
                value: 64,
                sample: .init(
                    type: .quantityType(forIdentifier: .bodyMass)!,
                    quantity: .init(unit: .gramUnit(with: .kilo), doubleValue: 64),
                    start: Date(),
                    end: Date()
                )
            )
        )
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
}
