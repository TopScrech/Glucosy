import ScrechKit
import SwiftData

struct HomeView: View {
    @Environment(AppRouter.self) private var router
    
    @State private var novoPenScanRequest = 0
    
    var body: some View {
        NavigationStack {
            TodayView(novoPenScanRequest: novoPenScanRequest)
        }
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
    }
}

#Preview {
    HomeView()
        .darkSchemePreferred()
        .environment(AppRouter())
        .environmentObject(ValueStore())
#if canImport(CoreNFC)
        .modelContainer(for: [SavedPen.self], inMemory: true)
#endif
}
