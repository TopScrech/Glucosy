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
            Section {
                Link(destination: URL(string: "https://github.com/TopScrech/Glucosy")!) {
                    HStack(spacing: 12) {
                        Image(.gitHub)
                            .resizable()
                            .frame(24)
                            .clipShape(.circle)
                        
                        Text("GitHub")
                    }
                }
                .tint(.primary)
            } footer: {
                Text("Bug reports, feature requests & contributions are always welcome!")
            }
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
