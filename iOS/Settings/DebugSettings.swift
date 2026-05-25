import SwiftUI

struct DebugSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        List {
            Toggle("Debug mode", isOn: $store.debugMode)
                .foregroundStyle(.foreground)
            
            Section {
                Toggle("Hide Status Bar", isOn: $store.debugHideStatusBar)
            }
#if canImport (CoreNFC)
            Section {
                NavigationLink("NovoPen Scan View") {
                    NovoPenReader()
                }
            }
#endif
        }
        .navigationTitle("Debug Settings")
    }
}

#Preview {
    List {
        DebugSettings()
    }
    .environmentObject(ValueStore())
}
