import ScrechKit
import HealthKit

struct InsulinCard: View {
    @EnvironmentObject private var store: ValueStore
    
    private let record: Insulin
    
    init(_ record: Insulin) {
        self.record = record
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: record.icon)
                .foregroundStyle(record.color)
                .title3()
            
            VStack(alignment: .leading) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text(Utils.formatNumber(record.value))
                            .title3(.semibold, design: .rounded)
                            .monospacedDigit()
                        
                        Text("U")
                            .caption()
                            .secondary()
                    }
                    
                    Text(record.type.title)
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
                Text("Copy Source")
                
                Text(record.source)
                
                Image(systemName: "doc.on.doc")
            }
        }
#endif
    }
}

#Preview {
    List {
        InsulinCard(
            Insulin(
                value: 16,
                type: .basal,
                sample: .init(
                    type: .quantityType(forIdentifier: .insulinDelivery)!,
                    quantity: .init(unit: .internationalUnit(), doubleValue: 5),
                    start: Date(),
                    end: Date()
                )
            )
        )
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
}
