import SwiftUI

struct NovoPenReader: View {
    @State var viewModel = PenReaderVM()
    @State private var healthKit = HealthKit()
    @EnvironmentObject private var store: ValueStore

    var body: some View {
        NavigationStack {
            List {
                ReaderStatusSection(viewModel: viewModel)
                ReaderActionsSection(viewModel: viewModel)
                ReaderDebugSection(
                    logText: viewModel.visibleLogText,
                    logCount: viewModel.logs.count,
                    fullLogFileURL: viewModel.logFileURL,
                    hasSavedLog: viewModel.hasSavedLog
                )

                if let reading = viewModel.reading {
                    PenSummarySection(reading: reading)
                    DoseHistorySection(
                        doses: viewModel.visibleDoses(using: store.airshotFilter),
                        matches: viewModel.doseMatches(using: healthKit.insulinRecords, airshotFilter: store.airshotFilter),
                        doseHistoryExportText: viewModel.doseHistoryExportText(using: store.airshotFilter)
                    )
                }
            }
            .navigationTitle("NovoPen Reader")
            .task {
                healthKit.authorize { _ in
                    Task { @MainActor in
                        healthKit.readInsulin()
                    }
                }
            }
        }
    }
}
