import ScrechKit
import WidgetKit

struct HomeView: View {
    @Environment(AppState.self) private var app: AppState
    @Environment(Log.self)      private var log: Log
    @Environment(History.self)  private var history: History
    @Environment(Settings.self) private var settings: Settings
    
    var body: some View {
        @Bindable var settings = settings
        @Bindable var app = app
        
        NavigationStack {
            TabView(selection: $settings.selectedTab) {
                NavigationView {
                    Monitor()
                }
                .tag(Tab.monitor)
                .tabItem {
                    Label("Monitor", systemImage: "gauge")
                }
                
                NavigationView {
                    DataView()
                }
                .tag(Tab.data)
                .tabItem {
                    Label("Data", systemImage: "tray.full.fill")
                }
                
                NavigationView {
                    AppleHealthView()
                }
                .tag(Tab.healthKit)
                .tabItem {
                    Label("Apple Health", systemImage: "heart")
                }
                
                NavigationView {
                    SettingsView()
                }
                .tag(Tab.settings)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                
                NavigationView {
                    OnlineView()
                }
                .tag(Tab.online)
                .tabItem {
                    Label("Online", systemImage: "globe")
                }
                
                NavigationView {
                    Plan()
                }
                .tag(Tab.plan)
                .tabItem {
                    Label("Plan", systemImage: "map")
                }
                
                NavigationView {
                    Console()
                }
                .tag(Tab.console)
                .tabItem {
                    Label("Console", systemImage: "terminal")
                }
                
                NavigationView {
                    DebugView()
                }
                .tag(Tab.debug)
                .tabItem {
                    Label("Debug", systemImage: "hammer")
                }
            }
            .onChange(of: app.main.app.currentGlucose) { _, newValue in
                delay(3) {
                    UIApplication.shared.inAppNotification(isDynamicIsland: true, timeout: 10, swipeToClose: true) { _ in // isDynamicIsland
                        NewRecordNotification($app.sheetMealtime)
                            .environment(app)
                    }
                }
            }
            .sheet($app.sheetMealtime) {
                NewRecordView()
            }
        }
    }
}

#Preview {
    HomeView()
        .glucosyPreview()
}

#Preview {
    HomeView()
        .glucosyPreview(.online)
}

#Preview {
    HomeView()
        .glucosyPreview(.data)
}

#Preview {
    HomeView()
        .glucosyPreview(.console)
}

#Preview {
    HomeView()
        .glucosyPreview(.settings)
}
