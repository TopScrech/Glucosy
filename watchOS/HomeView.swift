import ScrechKit

struct HomeView: View {
    @State private var vm = WatchRecordsViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(WatchRecordKind.allCases) { recordKind in
                    NavigationLink {
                        WatchRecordListView(recordKind: recordKind)
                    } label: {
                        Label(recordKind.title, systemImage: recordKind.systemImage)
                    }
                }
            }
            .navigationTitle("Records")
        }
        .environment(vm)
        .task {
            await vm.prepare()
        }
    }
}

#Preview {
    HomeView()
        .darkSchemePreferred()
}
