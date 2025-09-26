import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        TabView(selection: $store.selectedTab) {
            Tab("Today", systemImage: "heart.text.clipboard", value: 0) {
                TodayView()
            }
            
            Tab("Records", systemImage: "tray.full", value: 1) {
                RecordList()
            }
            
            Tab("Settings", systemImage: "gear", value: 2) {
                AppSettings()
            }
        }
        .sidebarAdaptableTabView()
    }
}

#Preview {
    HomeView()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
