import ScrechKit

struct WatchRecordListView: View {
    @Environment(WatchRecordsViewModel.self) private var vm
    
    let recordKind: WatchRecordKind
    
    private var entries: [WatchRecordEntry] {
        vm.entries(for: recordKind)
    }
    
    var body: some View {
        List {
            if let authorizationMessage = vm.authorizationMessage, entries.isEmpty {
                Text(authorizationMessage)
                    .secondary()
            } else if vm.isLoading(recordKind), entries.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if entries.isEmpty {
                Text(recordKind.emptyState)
                    .secondary()
            } else {
                ForEach(entries) {
                    WatchRecordRow(entry: $0)
                }
            }
        }
        .navigationTitle(recordKind.title)
        .task {
            await vm.loadIfNeeded(recordKind)
        }
        .refreshable {
            await vm.refresh(recordKind)
        }
    }
}
