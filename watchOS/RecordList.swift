import ScrechKit

struct RecordList: View {
    @Environment(WatchRecordsVM.self) private var vm
    
    private let recordKind: WatchRecordKind
    
    init(_ recordKind: WatchRecordKind) {
        self.recordKind = recordKind
    }
    
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
        .refreshableTask {
            await vm.refresh(recordKind)
        }
    }
}
