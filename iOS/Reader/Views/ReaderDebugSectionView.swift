import SwiftUI

struct ReaderDebugSectionView: View {
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

                Text("\(logCount) log entries")
                    .foregroundStyle(.secondary)

                if logCount > 80 {
                    Text("Showing the most recent 80 entries")
                        .foregroundStyle(.secondary)
                }

                DisclosureGroup(isExpanded: $isShowingLogs) {
                    Text(logText)
                        .font(.footnote.monospaced())
                        .textSelection(.enabled)
                } label: {
                    Label(isShowingLogs ? "Hide Logs" : "Show Logs", systemImage: "chevron.up.chevron.down")
                }
            }
        }
    }
}
