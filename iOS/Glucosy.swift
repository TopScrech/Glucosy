import ScrechKit

@main
struct GlucosyApp: App {
    @StateObject private var store = ValueStore()
    
    var body: some Scene {
        WindowGroup {
            AppContainer()
                .environmentObject(store)
        }
    }
}
