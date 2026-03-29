import SwiftUI
import SwiftData

struct AppContainer: View {
#if os(iOS)
    private let router = AppRouter.shared
#endif
    @StateObject private var store = ValueStore()
    
    var body: some View {
        HomeView()
#if os(iOS)
            .environment(router)
            .modelContainer(for: [SavedPen.self])
#endif
            .environmentObject(store)
#if canImport(Appearance)
            .preferredColorScheme(store.appearance.scheme)
#endif
    }
}
