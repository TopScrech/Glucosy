import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var app: AppState
    @Environment(Log.self) private var log: Log
    @Environment(History.self) private var history: History
    @Environment(Settings.self) private var settings: Settings
    
    var body: some View {
        @Bindable var settings = settings
        
        NavigationStack {
            TabView(selection: $settings.selectedTab) {
                SettingsView()
                    .tag(Tab.settings)
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                
                Monitor()
                    .tag(Tab.monitor)
                    .tabItem {
                        Label("Monitor", systemImage: "gauge")
                    }
                
                OnlineView()
                    .tag(Tab.online)
                    .tabItem {
                        Label("Online", systemImage: "globe")
                    }
                
                Console()
                    .tag(Tab.console)
                    .tabItem {
                        Label("Console", systemImage: "terminal")
                    }
                
                DataView()
                    .tag(Tab.data)
                    .tabItem {
                        Label("Data", systemImage: "tray.full.fill")
                    }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            // FIXME: often hangs
            .tabViewStyle(.verticalPage)
        }
    }
}

#Preview {
    HomeView()
        .glucosyPreview()
}
