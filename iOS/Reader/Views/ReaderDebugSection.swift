import SwiftUI

struct ReaderDebugSection: View {
    @Environment(PenReaderVM.self) private var vm
    
    @State private var isShowingLogs = false
    
    var body: some View {
        Section("Debug") {
            if !vm.hasSavedLog {
                Text("No logs yet")
                    .secondary()
            } else {
                ShareLink("Share Full Log", item: vm.logFileURL)
                
                DisclosureGroup(isExpanded: $isShowingLogs) {
                    Text(vm.visibleLogText)
                        .footnote()
                        .monospaced()
                        .textSelection(.enabled)
                } label: {
                    Label(isShowingLogs ? "Hide Logs" : "Show Logs", systemImage: "chevron.up.chevron.down")
                }
            }
        }
    }
}
