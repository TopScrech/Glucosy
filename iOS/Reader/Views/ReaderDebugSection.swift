import SwiftUI

struct ReaderDebugSection: View {
    let logText: String
    let logCount: Int
    let fullLogFileURL: URL
    let hasSavedLog: Bool
    @State private var isShowingLogs = false

    var body: some View {
        Section("Debug") {
            if !hasSavedLog {
                Text("No logs yet")
                    .foregroundStyle(.secondary)
            } else {
                ShareLink("Share Full Log", item: fullLogFileURL)

                DisclosureGroup(isExpanded: $isShowingLogs) {
                    Text(logText)
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
