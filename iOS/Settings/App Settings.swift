import SwiftUI

struct AppSettings: View {
    @EnvironmentObject private var storage: ValueStorage
    
    var body: some View {
        List {
            Toggle("Debug mode", isOn: $storage.debugMode)
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    AppSettings()
        .environmentObject(ValueStorage())
}
