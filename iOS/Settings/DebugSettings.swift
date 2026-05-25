import SwiftUI

struct DebugSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        List {
            Toggle(isOn: $store.debugMode) {
                Label("Debug mode", systemImage: "hammer")
            }
            .foregroundStyle(.foreground)
            
            Toggle("Hide Status Bar", isOn: $store.debugHideStatusBar)
#if canImport (CoreNFC)
            NavigationLink("NovoPen Scan View") {
                NovoPenReader()
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
