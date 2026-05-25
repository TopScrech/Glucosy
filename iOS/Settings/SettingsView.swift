import ScrechKit
import Appearance

struct SettingsView: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        List {
            Section("General") {
#if !os(visionOS)
                AppearancePicker($store.appearance)
                    .foregroundStyle(.foreground)
#endif
                Button("Change language", systemImage: "globe") {
                    openSettings()
                }
                .foregroundStyle(.foreground)
            }
            
            GlucoseUnitPicker()
#if canImport(CoreNFC)
            SettingsNovopenSection()
#endif
        }
        .navigationTitle("Settings")
        .toolbar {
            NavigationLink {
                DebugSettings()
            } label: {
                Image(systemName: "hammer")
                    .footnote()
            }
        }
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
