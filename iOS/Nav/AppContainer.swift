import SwiftUI
import SwiftData

#if canImport(Appearance)
import Appearance
#endif

struct AppContainer: View {
    private let router = AppRouter.shared
    @StateObject private var store = ValueStore()
    
    var body: some View {
        HomeView()
            .environment(router)
#if canImport(CoreNFC)
            .modelContainer(for: [SavedPen.self])
#endif
#if os(iOS)
            .statusBarHidden(store.debugHideStatusBar)
#endif
            .environmentObject(store)
#if canImport(Appearance)
            .preferredColorScheme(store.appearance.scheme)
#endif
    }
}
