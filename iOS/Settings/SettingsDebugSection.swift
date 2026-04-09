import SwiftUI

struct SettingsDebugSection: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        Section("Debug Settings") {
            Toggle(String("Hide Status Bar"), isOn: $store.debugHideStatusBar)
            
            NavigationLink("NovoPen Scan View") {
                NovoPenReader()
            }
        }
    }
}

#Preview {
    List {
        SettingsDebugSection()
    }
    .environmentObject(ValueStore())
}
