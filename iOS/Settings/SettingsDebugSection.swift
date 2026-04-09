import SwiftUI

struct SettingsDebugSection: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        Section("Debug Settings") {
            Toggle(String("Hide Status Bar"), isOn: $store.debugHideStatusBar)
#if canImport (CoreNFC)
            NavigationLink("NovoPen Scan View") {
                NovoPenReader()
            }
#endif
        }
    }
}

#Preview {
    List {
        SettingsDebugSection()
    }
    .environmentObject(ValueStore())
}
