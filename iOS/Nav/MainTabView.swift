#if os(iOS)
import SwiftUI

struct MainTabView: View {
    @AppStorage("selected_tab") private var selection: AppTab = .home

    let assistantRequest: Int
    let novoPenScanRequest: Int

    var body: some View {
        TabView(selection: $selection) {
            Tab("Home", systemImage: "house", value: AppTab.home) {
                HomeNavigationView(
                    assistantRequest: assistantRequest,
                    novoPenScanRequest: novoPenScanRequest
                )
            }

            Tab("Calories", systemImage: "flame", value: AppTab.calories) {
                CaloriesView()
            }
        }
        .onChange(of: assistantRequest) {
            selection = .home
        }
        .onChange(of: novoPenScanRequest) {
            selection = .home
        }
    }
}
#endif
