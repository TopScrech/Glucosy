import ScrechKit

@main
struct GlucosyApp: App {
    @StateObject private var settings = ValueStore()
    
    var body: some Scene {
        WindowGroup {
            AppContainer()
                .environmentObject(settings)
        }
    }
}
