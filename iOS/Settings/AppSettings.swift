import SwiftUI
import Appearance

struct AppSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        List {
#if !os(visionOS)
            AppearancePicker($store.appearance)
#endif

            Section("Units") {
                Picker("Glucose", selection: $store.glucoseUnit) {
                    ForEach(GlucoseUnit.allCases) {
                        Text($0.title)
                            .tag($0)
                    }
                }
            }

            Section {
                Toggle(isOn: $store.debugMode) {
                    Label("Debug mode", systemImage: "hammer")
                }
            }

            Section("NovoPen") {
                NavigationLink("NovoPen Reader") {
                    NovoPenReader()
                }
                
                Picker("Hide Airshots", selection: $store.airshotFilter) {
                    ForEach(AirshotFilter.allCases) {
                        Text($0.title)
                            .tag($0)
                    }
                }
            }
        }
    }
}

#Preview {
    AppSettings()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
