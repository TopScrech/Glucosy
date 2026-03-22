import SwiftUI

struct NovoPenReaderView: View {
    @State var viewModel = PenReaderViewModel()

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
                    DoseHistorySectionView(doses: reading.doses, doseHistoryExportText: viewModel.doseHistoryExportText)
                }
            }
            .navigationTitle("NovoPen Reader")
        }
    }
}
