import ScrechKit
import HealthKit

struct WeightRecordCard: View {
    @Environment(HealthKit.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    private let record: Weight
    
    init(_ record: Weight) {
        self.record = record
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
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button("Delete", systemImage: "trash", role: .destructive) {
                vm.deleteWeight(record)
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
                    vm.deleteWeight(record)
                }
            }
        }
    }
}

#Preview {
    List {
        WeightRecordCard(
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
