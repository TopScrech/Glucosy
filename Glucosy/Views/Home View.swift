import ScrechKit

struct HomeView: View {
    @Environment(AppState.self) private var app: AppState
    @Environment(Log.self) private var log: Log
    @Environment(History.self) private var history: History
    @Environment(Settings.self) private var settings: Settings
    
    var body: some View {
        @Bindable var settings = settings
        @Bindable var app = app
        
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
        }
        .toolbarRole(.navigationStack)
        .onChange(of: app.main.app.currentGlucose) { _, _ in
            delay(3) {
                app.sheetMealtime = true
            }
        }
        .sheet($app.sheetMealtime) {
            MealtimeView()
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