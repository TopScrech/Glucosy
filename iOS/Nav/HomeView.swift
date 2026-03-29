import SwiftUI

struct HomeView: View {
    @Environment(AppRouter.self) private var router
    @State private var showsNovoPenReader = false
    
    var body: some View {
        NavigationStack {
            TodayView(openNovoPenScan: openNovoPenScan)
                .navigationDestination(isPresented: $showsNovoPenReader) {
                    NovoPenReader(startsScanningOnAppear: true)
                }
        }
        .task(id: router.actionRequest) {
            guard router.actionRequest > 0 else {
                return
            }
            
            guard let action = router.consumePendingAction() else {
                return
            }
            
            switch action {
            case .startNovoPenScan:
                await presentNovoPenReader()
            }
        }
    }
    
    private func openNovoPenScan() {
        Task {
            await presentNovoPenReader()
        }
    }
    
    private func presentNovoPenReader() async {
        if showsNovoPenReader {
            showsNovoPenReader = false
            await Task.yield()
        }
        
        showsNovoPenReader = true
    }
}

#Preview {
    HomeView()
        .environment(AppRouter())
        .darkSchemePreferred()
}
