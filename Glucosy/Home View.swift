import SwiftUI

struct HomeView: View {
    @AppStorage("selected_tab") private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tag(0)
                .tabItem {
                    Label("Today", systemImage: "heart.text.clipboard")
                }
            
            RecordList()
                .tag(1)
                .tabItem {
                    Label("Records", systemImage: "tray.full")
                }
            
            AppSettings()
                .tag(2)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}

#Preview {
    HomeView()
}
