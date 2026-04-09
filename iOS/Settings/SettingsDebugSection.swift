import SwiftUI

struct SettingsDebugSection: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        if store.debugMode {
            Section("Debug Settings") {
                Toggle(String("Hide Status Bar"), isOn: $store.debugHideStatusBar)
                
                NavigationLink("NovoPen Scan View") {
                    NovoPenReader()
                }
            }
        }
    }
}

#Preview {
    SettingsDebugSection()
        .environmentObject(ValueStore())
}
