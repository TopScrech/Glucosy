import ScrechKit
import HealthKit

struct CarbsRecordCard: View {
    @Environment(HealthKit.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    private let record: Carbs
    
    init(_ record: Carbs) {
        self.record = record
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "fork.knife")
                .foregroundStyle(record.color)
                .title3()
            
            VStack(alignment: .leading) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(Utils.formatNumber(record.value))
                        .title3(.semibold, design: .rounded)
                    
                    Text("g")
                        .caption()
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
                vm.deleteCarbs(record)
            }
        }
        .contextMenu {
#if DEBUG
            Button {
                UIPasteboard.general.string = record.source
            } label: {
                Text(String("Copy Source"))
                
                Text(record.source)
                
                Image(systemName: "doc.on.doc")
            }
#endif
            Section {
                Button("Delete", systemImage: "trash", role: .destructive) {
                    vm.deleteCarbs(record)
                }
            }
        }
    }
}

#Preview {
    List {
        CarbsRecordCard(
            Carbs(
                value: 32,
                sample: .init(
                    type: .quantityType(forIdentifier: .dietaryCarbohydrates)!,
                    quantity: .init(unit: .gram(), doubleValue: 32),
                    start: Date(),
                    end: Date()
                )
            )
        )
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
}
