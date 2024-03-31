import SwiftUI

struct InsulinCard: View {
    @EnvironmentObject private var storage: Storage
    
    let insulin: InsulinDelivery
    
    init(_ insulin: InsulinDelivery) {
        self.insulin = insulin
    }
    
    var body: some View {
        HStack {
            if insulin.type == .bolus {
                Image(systemName: "syringe")
            } else {
                Image(systemName: "syringe.fill")
                    .foregroundStyle(.purple)
            }
            
            Text(insulin.value)
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(timeFromDate(insulin.date))
                    .footnote()
                    .foregroundStyle(.secondary)
                
                if storage.debugMode {
                    if let sourceBundleId {
                        Text(sourceBundleId)
                            .caption2()
                            .foregroundStyle(.tertiary)
                    }
                } else {
                    if let sourceName {
                        Text(sourceName)
                            .caption2()
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
        .monospacedDigit()
    }
}

#Preview {
    List {
        InsulinCard(.init(value: 16, type: .bolus, date: Date()))
        InsulinCard(.init(value: 8, type: .basal, date: Date()))
    }
    .darkSchemePreferred()
    .environmentObject(Storage())
}
