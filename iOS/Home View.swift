import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        TabView(selection: $store.selectedTab) {
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
        .sidebarAdaptableTabView()
    }
}

#Preview {
    HomeView()
        .environmentObject(ValueStore())
}
