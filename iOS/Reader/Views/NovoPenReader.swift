import SwiftUI

struct NovoPenReader: View {
    let startsScanningOnAppear: Bool
    
    @State var vm = PenReaderVM()
    @State private var healthKit = HealthKit()
    @State private var hasStartedInitialScan = false
    @EnvironmentObject private var store: ValueStore

    var body: some View {
        List {
            ReaderStatusSection(vm: vm)
            ReaderActionsSection(vm: vm)
            ReaderDebugSection(
                logText: vm.visibleLogText,
                logCount: vm.logs.count,
                fullLogFileURL: vm.logFileURL,
                hasSavedLog: vm.hasSavedLog
            )

            if let reading = vm.reading {
                PenSummarySection(reading: reading)
                DoseHistorySection(
                    doses: vm.visibleDoses(using: store.airshotFilter),
                    matches: vm.doseMatches(using: healthKit.insulinRecords, airshotFilter: store.airshotFilter),
                    doseHistoryExportText: vm.doseHistoryExportText(using: store.airshotFilter)
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
            vm.startScan()
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
