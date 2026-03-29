import SwiftUI
import HealthKit

struct WeightCard: View {
    @EnvironmentObject private var store: ValueStore
    
    private let record: Weight
    
    init(_ record: Weight) {
        self.record = record
    }
    
    private var sourceId: String {
        record.sample.sourceRevision.source.bundleIdentifier
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "scalemass")
                .foregroundStyle(.blue)
                .title3()
            
            VStack(alignment: .leading) {
                HStack(spacing: 5) {
                    Text(record.value, format: .number.precision(.fractionLength(1)))
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
                    SourceImage(sourceId)
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
