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
    
    private var color: Color {
        .blue
    }
    
    private var formattedValue: String {
        String(Int(record.value.rounded()))
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 4) {
                Image(systemName: "scalemass")
                    .foregroundStyle(color)
                    .title2()
                
                Text(formattedValue)
                    .title3(.semibold, design: .rounded)
                
                Text("KG")
                    .caption2()
                    .secondary()
            }
            .padding(10)
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
            .padding(1)
            .background(color, in: .rect(cornerRadius: 17))
            
            HStack(spacing: 4) {
                Text(record.date, format: .dateTime.hour().minute())
                    .secondary()
                    .caption2()
                
                if store.debugMode {
                    SourceImage(sourceId)
                }
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
