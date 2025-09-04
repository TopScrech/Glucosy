import SwiftUI

struct AppSettings: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        List {
            Toggle("Debug mode", isOn: $store.debugMode)
        }
    }
}

#Preview {
    AppSettings()
        .environmentObject(ValueStore())
}
