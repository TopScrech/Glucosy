import SwiftUI

struct HomeNavigationView: View {
    let assistantRequest: Int
    let novoPenScanRequest: Int

    var body: some View {
        NavigationStack {
            HomeView(
                assistantRequest: assistantRequest,
                novoPenScanRequest: novoPenScanRequest
            )
        }
    }
}
