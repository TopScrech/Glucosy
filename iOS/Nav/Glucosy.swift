import ScrechKit

#if os(iOS)
import UIKit
#endif

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
