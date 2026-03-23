import SwiftUI

struct NovoPenReaderView: View {
    @State var viewModel = PenReaderViewModel()
    @State private var healthKit = HealthKit()
    @EnvironmentObject private var store: ValueStore

    var body: some View {
        NavigationStack {
            List {
                ReaderStatusSectionView(viewModel: viewModel)
                ReaderActionsSectionView(viewModel: viewModel)
                ReaderDebugSectionView(
                    logText: viewModel.visibleLogText,
                    logCount: viewModel.logs.count,
                    fullLogFileURL: viewModel.logFileURL,
                    hasSavedLog: viewModel.hasSavedLog
                )

                if let reading = viewModel.reading {
                    PenSummarySectionView(reading: reading)
                    DoseHistorySectionView(
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
