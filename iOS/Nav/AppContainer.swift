import SwiftUI
import SwiftData

#if canImport(LGAlert) && os(visionOS)
import LGAlert
#endif

#if canImport(Appearance)
import Appearance
#endif

struct AppContainer: View {
    private let router = AppRouter.shared
    @StateObject private var store = ValueStore()
    
    @State private var novoPenScanRequest = 0
    
    var body: some View {
        Group {
#if canImport(LGAlert) && os(visionOS)
            if #available(iOS 26, visionOS 26, *) {
                NavigationStack {
#if os(watchOS)
                    HomeView()
#else
                    HomeView(novoPenScanRequest: novoPenScanRequest)
#endif
                }
                .toastRoot()
            } else {
                NavigationStack {
#if os(watchOS)
                    HomeView()
#else
                    HomeView(novoPenScanRequest: novoPenScanRequest)
#endif
                }
            }
#else
            NavigationStack {
#if os(watchOS)
                HomeView()
#else
                HomeView(novoPenScanRequest: novoPenScanRequest)
#endif
            }
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
#if canImport(CoreNFC)
        .task {
            deleteSavedReaderLogIfNeeded()
        }
        .onChange(of: store.debugMode) { _, _ in
            deleteSavedReaderLogIfNeeded()
        }
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
    
#if canImport(CoreNFC)
    private func deleteSavedReaderLogIfNeeded() {
        guard !store.debugMode else {
            return
        }
        
        ReaderLogStore().delete()
    }
#endif
}
