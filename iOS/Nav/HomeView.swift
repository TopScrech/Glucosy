import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        TabView(selection: $store.selectedTab) {
            Tab("Today", systemImage: "heart.text.clipboard", value: 0) {
                NavigationStack {
                    TodayView()
                }
            }
            
            Tab("Records", systemImage: "tray.full", value: 1) {
                NavigationStack {
                    RecordList()
                }
            }
            
            Tab("Settings", systemImage: "gear", value: 2) {
                NavigationStack {
                    AppSettings()
                }
            }
        }
        .sidebarAdaptableTabView()
        .task {
            store.normalizeSelectedTab()
        }
    }
}

#Preview {
    HomeView()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
