import SwiftUI

struct GlucoseUnitPicker: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        Section("Units") {
            HStack {
                Text("Glucose")
                
                Spacer(minLength: 80)
                
                Picker("Glucose", selection: $store.glucoseUnit) {
                    ForEach(GlucoseUnit.allCases) {
                        Text($0.title)
                            .tag($0)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

#Preview {
    List {
        GlucoseUnitPicker()
    }
    .environmentObject(ValueStore())
}
