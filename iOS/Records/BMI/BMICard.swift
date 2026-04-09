import SwiftUI
import HealthKit

struct BMICard: View {
    @EnvironmentObject private var store: ValueStore
    
    private let record: BMI
    
    init(_ record: BMI) {
        self.record = record
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "figure")
                .foregroundStyle(.mint)
                .title3()
            
            VStack(alignment: .leading) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(record.value, format: .number.precision(.fractionLength(1)))
                        .title3(.semibold, design: .rounded)
                        .monospacedDigit()
                    
                    Text("BMI")
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
        BMICard(
            BMI(
                value: 22.4,
                sample: .init(
                    type: .quantityType(forIdentifier: .bodyMassIndex)!,
                    quantity: .init(unit: .count(), doubleValue: 22.4),
                    start: Date(),
                    end: Date()
                )
            )
        )
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
}
