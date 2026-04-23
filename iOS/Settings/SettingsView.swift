import ScrechKit
import Appearance

struct SettingsView: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        List {
#if !os(visionOS)
            AppearancePicker($store.appearance)
                .foregroundStyle(.foreground)
#endif
            Button("Change language", systemImage: "globe") {
                openSettings()
            }
            .foregroundStyle(.foreground)
            
            GlucoseUnitPicker()
#if canImport(CoreNFC)
            SettingsNovopenSection()
#endif
            Section {
                Toggle(isOn: $store.debugMode) {
                    Label("Debug mode", systemImage: "hammer")
                }
                .foregroundStyle(.foreground)
            }
            
            if store.debugMode {
                SettingsDebugSection()
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
#if canImport(CoreNFC)
        .modelContainer(for: [SavedPen.self], inMemory: true)
#endif
}
