import ScrechKit

@main
struct GlucosyApp: App {
#if os(iOS)
    @UIApplicationDelegateAdaptor(GlucosyAppDelegate.self) private var appDelegate
#endif
    
    var body: some Scene {
        WindowGroup {
            AppContainer()
        }
    }
}
