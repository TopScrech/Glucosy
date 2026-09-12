import SwiftUI

struct CaloriesView: View {
    var body: some View {
        NavigationStack {
            HomeView(
                assistantRequest: 0,
                novoPenScanRequest: 0,
                showsCalories: true
            )
        }
    }
}
