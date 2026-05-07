import SwiftUI

struct NovoPenReader: View {
    @State private var healthKit = HealthKit()
    @EnvironmentObject private var store: ValueStore
    
    private let startsScanningOnAppear: Bool
    
    init(startsScanningOnAppear: Bool = false) {
        self.startsScanningOnAppear = startsScanningOnAppear
    }
    
    @State var vm = PenReaderVM()
    @State private var hasStartedInitialScan = false
    
    var body: some View {
        List {
            ReaderStatusSection()
            ReaderActionsSection()
            ReaderDebugSection()
            
            if let reading = vm.reading {
                PenSummarySection(reading)
                DoseHistorySection()
            }
        }
        .navigationTitle("NovoPen Reader")
        .environment(vm)
        .onChange(of: store.debugMode) { _, newValue in
            vm.setPersistentLoggingEnabled(newValue)
        }
        .task {
            vm.setPersistentLoggingEnabled(store.debugMode)
            
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
}

#Preview {
    NavigationStack {
        NovoPenReader()
            .environmentObject(ValueStore())
    }
}
