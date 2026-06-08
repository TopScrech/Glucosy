import ScrechKit

struct DebugSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    private var version: String {
        "v\(Bundle.version ?? "Unknown") (B\(Bundle.build ?? "Unknown"))"
    }
    
    var body: some View {
        List {
            Section {
                LabeledContent("App Version", value: version)
                
                Toggle("Debug mode", isOn: $store.debugMode)
                    .foregroundStyle(.foreground)
            }
            
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
