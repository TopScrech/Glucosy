import SwiftUI

struct GlucoseCard: View {
    @EnvironmentObject private var storage: Storage
    
    let glucose: Glucose
    
    init(_ glucose: Glucose) {
        self.glucose = glucose
    }
    
    var body: some View {
        HStack {
            Text(glucose.value.units)
                .bold()
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(date)
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
        GlucoseCard(History.test.glucose.first!)
    }
    .darkSchemePreferred()
    .environmentObject(Storage())
}
