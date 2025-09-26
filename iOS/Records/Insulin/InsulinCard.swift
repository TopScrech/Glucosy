import SwiftUI
import HealthKit

struct InsulinCard: View {
    @EnvironmentObject private var store: ValueStore
    
    private let record: Insulin
    
    init(_ record: Insulin) {
        self.record = record
    }
    
    private var isBasal: Bool {
        record.type == .basal
    }
    
    private var icon: String {
        isBasal ? "syringe.fill" : "syringe"
    }
    
    private var color: Color {
        isBasal ? .purple : .yellow
    }
    
    private var sourceId: String {
        record.sample.sourceRevision.source.bundleIdentifier
    }
    
    var body: some View {
        VStack {
            VStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .fontSize(30)
                
                Text(Utils.formatNumber(record.value))
                    .title3(.semibold, design: .rounded)
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
