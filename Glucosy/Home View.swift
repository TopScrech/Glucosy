import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            Tab("Today", systemImage: "heart.text.clipboard") {
                TodayView()
            }
            
            Tab("Records", systemImage: "tray.full") {
                RecordList()
            }
            
            Tab("Settings", systemImage: "gear") {
                AppSettings()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}

#Preview {
    HomeView()
}
