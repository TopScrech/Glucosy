import SwiftUI

struct AppContainer: View {
#if os(iOS)
    private let router = AppRouter.shared
#endif
    @StateObject private var store = ValueStore()
    
    var body: some View {
        HomeView()
#if os(iOS)
        .environment(router)
#endif
        .environmentObject(store)
#if canImport(Appearance)
        .preferredColorScheme(store.appearance.scheme)
#endif
    }
}
