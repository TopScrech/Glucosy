import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            TodayView()
        }
    }
}

#Preview {
    HomeView()
        .darkSchemePreferred()
}
