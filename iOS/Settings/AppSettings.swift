import SwiftUI
import Appearance

struct AppSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        List {
#if !os(visionOS)
            AppearancePicker($store.appearance)
#endif
            GlucoseUnitPicker()
#if canImport(CoreNFC)
            SettingsNovopenSection()
#endif
            Section {
                Toggle(isOn: $store.debugMode) {
                    Label("Debug mode", systemImage: "hammer")
                }
            }
            
            if store.debugMode {
                SettingsDebugSection()
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    AppSettings()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
#if canImport(CoreNFC)
        .modelContainer(for: [SavedPen.self], inMemory: true)
#endif
}
