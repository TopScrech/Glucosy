import ScrechKit
import SwiftData

@main
struct GlucosyApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
#if !os(watchOS)
    @UIApplicationDelegateAdaptor(MainDelegate.self) private var main
#else
    @WKApplicationDelegateAdaptor(MainDelegate.self) private var main
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
    
#if os(iOS)
    @State private var overlayWindow: PassThroughWindow?
#endif
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .defaultAppStorage(.init(suiteName: "group.dev.topscrech.Health-Point")!)
                .modelContainer(container)
                .environment(main.app)
                .environment(main.log)
                .environment(main.history)
                .environment(main.settings)
#if os(iOS)
                .onOpenURL { url in
                    switch url.description {
                    case "action/nfc":
                        if main.nfc.isAvailable {
                            main.nfc.startSession()
                        } else {
                            print("NFC is unavailible")
                        }
                        
                    case "action/new_record":
                        main.app.sheetMealtime = true
                        
                    default:
                        print("Deeplinking")
                    }
                }
                .onAppear {
                    if overlayWindow == nil {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            let overlayWindow = PassThroughWindow(windowScene: windowScene)
                            overlayWindow.backgroundColor = .clear
                            overlayWindow.tag = 0320
                            
                            let controller = StatusBarBasedController()
                            controller.view.backgroundColor = .clear
                            
                            overlayWindow.rootViewController = controller
                            overlayWindow.isHidden = false
                            overlayWindow.isUserInteractionEnabled = true
                            self.overlayWindow = overlayWindow
                            
                            print("Overlay Window Created")
                        }
                    }
                }
#endif
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
