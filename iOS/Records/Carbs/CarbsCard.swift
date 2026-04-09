import ScrechKit
import HealthKit

struct CarbsCard: View {
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
#if DEBUG
        .contextMenu {
            Button {
                UIPasteboard.general.string = record.source
            } label: {
                Text(String("Copy Source"))
                
                Text(record.source)
                
                Image(systemName: "doc.on.doc")
            }
        }
#endif
    }
}

#Preview {
    List {
        CarbsCard(
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
