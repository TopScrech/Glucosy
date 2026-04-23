import SwiftUI
import SwiftData

#if canImport(Appearance)
import Appearance
#endif

struct AppContainer: View {
    private let router = AppRouter.shared
    @StateObject private var store = ValueStore()
    
    @State private var novoPenScanRequest = 0
    
    var body: some View {
        NavigationStack {
#if os(watchOS)
            HomeView()
#else
            HomeView(novoPenScanRequest: novoPenScanRequest)
#endif
        }
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
#if !os(watchOS)
        .task(id: router.actionRequest) {
            guard
                router.actionRequest > 0,
                let action = router.consumePendingAction()
            else {
                return
            }
            
            switch action {
            case .startNovoPenScan:
                novoPenScanRequest += 1
            }
        }
#endif
    }
}
