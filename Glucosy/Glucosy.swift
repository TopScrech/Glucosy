import ScrechKit

@main
struct GlucosyApp: App {
    @StateObject private var settings = ValueStorage()
    
    var body: some Scene {
        WindowGroup {
            AppContainer()
                .environmentObject(settings)
        }
    }
}
