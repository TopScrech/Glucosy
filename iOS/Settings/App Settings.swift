import SwiftUI

struct AppSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        List {
            Toggle("Debug mode", isOn: $store.debugMode)
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    AppSettings()
        .environmentObject(ValueStore())
}
