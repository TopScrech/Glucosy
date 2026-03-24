import SwiftUI

struct AppContainer: View {
    @StateObject private var store = ValueStore()
    
    var body: some View {
        HomeView()
        .environmentObject(store)
#if canImport(Appearance)
        .preferredColorScheme(store.appearance.scheme)
#endif
    }
}
