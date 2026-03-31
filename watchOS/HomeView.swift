import ScrechKit

struct HomeView: View {
    var body: some View {
        let recordLists: [(title: String, systemImage: String, emptyState: String)] = [
            ("Blood Glucose", "drop", "No blood glucose records yet"),
            ("Insulin Delivery", "syringe", "No insulin records yet"),
            ("Carbohydrates", "fork.knife", "No carbohydrate records yet"),
            ("Weight", "scalemass", "No weight records yet")
        ]
        
        return NavigationStack {
            List {
                ForEach(recordLists, id: \.title) { recordList in
                    NavigationLink {
                        List {
                            Text(recordList.emptyState)
                                .secondary()
                        }
                        .navigationTitle(recordList.title)
                    } label: {
                        Label(recordList.title, systemImage: recordList.systemImage)
                    }
                }
            }
            .navigationTitle("Records")
        }
    }
}

#Preview {
    HomeView()
        .darkSchemePreferred()
}
