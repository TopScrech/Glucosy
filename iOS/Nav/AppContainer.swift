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
#if canImport(CoreNFC)
    @State private var novoPenScanToast: NovoPenScanToast?
    @State private var novoPenScanToastDismissTask: Task<Void, Never>?
#endif
    
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
        .overlay(alignment: .bottom) {
            if let novoPenScanToast {
                NovoPenScanToastView(
                    title: novoPenScanToast.title,
                    showsViewAll: novoPenScanToast.showsViewAll,
                    viewAll: {
                        dismissNovoPenScanToast()
                        novoPenScanToast.viewAll()
                    },
                    dismiss: dismissNovoPenScanToast
                )
                .padding(.horizontal)
                .padding(.bottom)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .environment(\.showNovoPenScanToast, showNovoPenScanToast)
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
    private func showNovoPenScanToast(_ toast: NovoPenScanToast) {
        withAnimation(.interpolatingSpring(duration: 0.35, bounce: 0)) {
            novoPenScanToast = toast
        }
        
        novoPenScanToastDismissTask?.cancel()
        novoPenScanToastDismissTask = Task {
            do {
                try await Task.sleep(for: .seconds(5))
                
                guard novoPenScanToast?.title == toast.title else {
                    return
                }
                
                dismissNovoPenScanToast()
            } catch {
                
            }
        }
    }
    
    private func dismissNovoPenScanToast() {
        withAnimation(.interpolatingSpring(duration: 0.35, bounce: 0)) {
            novoPenScanToast = nil
        }
        
        novoPenScanToastDismissTask?.cancel()
        novoPenScanToastDismissTask = nil
    }
    
    private func deleteSavedReaderLogIfNeeded() {
        guard !store.debugMode else {
            return
        }
        
        ReaderLogStore().delete()
    }
#endif
}
