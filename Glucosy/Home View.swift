import SwiftUI

struct HomeView: View {
    @AppStorage("selected_tab") private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
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

struct Tab<Content: View, Tag: Hashable>: View {
    let title: LocalizedStringKey
    let systemImage: String
    let value: Tag
    let content: Content
    
    init(_ title: LocalizedStringKey, systemImage: String, value: Tag, @ViewBuilder content: () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self.value = value
        self.content = content()
    }
    
    var body: some View {
        if #available(iOS 18, macOS 15, tvOS 18, watchOS 11, visionOS 2, *) {
            Tab(title, systemImage: systemImage, value: value) {
                content
            }
        } else {
            content
                .tag(value)
                .tabItem {
                    Label(title, systemImage: systemImage)
                }
        }
    }
}

#Preview {
    HomeView()
}
