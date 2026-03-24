import SwiftUI

struct NovoPenReader: View {
    let startsScanningOnAppear: Bool
    
    @State var viewModel = PenReaderVM()
    @State private var healthKit = HealthKit()
    @State private var hasStartedInitialScan = false
    @EnvironmentObject private var store: ValueStore

    var body: some View {
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
            
            guard startsScanningOnAppear, !hasStartedInitialScan else {
                return
            }
            
            hasStartedInitialScan = true
            viewModel.startScan()
        }
    }
    
    init(startsScanningOnAppear: Bool = false) {
        self.startsScanningOnAppear = startsScanningOnAppear
    }
}

#Preview {
    NavigationStack {
        NovoPenReader()
            .environmentObject(ValueStore())
    }
}
