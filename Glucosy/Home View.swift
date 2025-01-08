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
        .sidebarAdaptableTabView()
    }
}

#warning("Move to ScreckKit")
public struct SidebarAdoptableTabView: ViewModifier {
    public func body(content: Content) -> some View {
        if #available(iOS 18, macOS 15, tvOS 18, visionOS 2, *) {
            content
                .tabViewStyle(.sidebarAdaptable)
        } else {
            content
        }
    }
}

public extension View {
    func sidebarAdaptableTabView() -> some View {
        modifier(SidebarAdoptableTabView())
    }
}

#Preview {
    HomeView()
}
