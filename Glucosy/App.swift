import ScrechKit
import SwiftData

@main
struct GlucosyApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
#if !os(watchOS)
    @UIApplicationDelegateAdaptor(MainDelegate.self) var main
#else
    @WKApplicationDelegateAdaptor(MainDelegate.self) var main
#endif
    
    private let container: ModelContainer
    
    init() {
        let schema = Schema([
            Pen.self
        ])
        
        do {
            container = try ModelContainer(for: schema)
        } catch {
            fatalError("Failed to create model container")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .modelContainer(container)
                .environment(main.app)
                .environment(main.log)
                .environment(main.history)
                .environment(main.settings)
        }
        .onChange(of: scenePhase) {
#if !os(watchOS)
            if scenePhase == .active {
                UIApplication.shared.isIdleTimerDisabled = main.settings.caffeinated
            }
#endif
            
            if scenePhase == .background {
                if main.settings.userLevel >= .devel {
                    main.debugLog("DEBUG: app went background at \(Date.now.shortTime)")
                }
            }
        }
    }
}
