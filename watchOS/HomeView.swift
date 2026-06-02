import ScrechKit

struct HomeView: View {
    @State private var vm = WatchRecordsVM()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(WatchRecordKind.allCases) { recordKind in
                    NavigationLink {
                        RecordList(recordKind)
                            .environment(vm)
                    } label: {
                        Label(recordKind.title, systemImage: recordKind.systemImage)
                    }
                }
            }
            .navigationTitle("Records")
        }
        .task {
            await vm.prepare()
        }
    }
}

#Preview {
    HomeView()
        .darkSchemePreferred()
}
