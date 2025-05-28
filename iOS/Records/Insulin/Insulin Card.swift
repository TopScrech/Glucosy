import SwiftUI
import HealthKit

struct InsulinCard: View {
    @EnvironmentObject private var storage: ValueStorage
    
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
        HStack {
            SourceImage(sourceId)
            
            VStack(alignment: .leading) {
                HStack(spacing: 3) {
                    Image(systemName: icon)
                        .foregroundStyle(color)
                    
                    Text(Utils.formatNumber(record.value))
                }
                
                if storage.debugMode {
                    SourceName(record.source)
                }
            }
            
            Spacer()
            
            Text(record.date, format: .dateTime.hour().minute())
                .secondary()
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
    .environmentObject(ValueStorage())
}
