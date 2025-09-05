import SwiftUI

struct AppContainer: View {
    @StateObject private var store = ValueStore()
    
    var body: some View {
        NavigationStack {
            HomeView()
        }
        .environmentObject(store)
        .preferredColorScheme(store.appearance.scheme)
    }
}
