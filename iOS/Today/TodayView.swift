import ScrechKit
import OSLog
import SwiftData

struct TodayView: View {
    @State private var vm = HealthKit()
#if canImport(CoreNFC)
    @State private var novoPenReader = PenReaderVM()
    @State private var novoPenWriteConfirmation = NovoPenWriteConfirmationVM()
    @Query(sort: \SavedPen.createdAt) private var savedPens: [SavedPen]
    @State private var scannedPenToSave: PenReading?
    @State private var novoPenScanErrorMessage: String?
    @State private var showsNovoPenScanError = false
    @State private var showsNovoPenWriteConfirmation = false
#endif
    @EnvironmentObject private var store: ValueStore
    
    let novoPenScanRequest: Int
    
    @State private var showsSettings = false
    @State private var sheetNewInsulinRecord = false
    @State private var sheetNewCarbsRecord = false
    @State private var sheetNewGlucoseRecord = false
    @State private var sheetNewWeightRecord = false
    
    var body: some View {
        let glucoseUnit = store.glucoseUnit

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                TodayMetricsSection(metrics: metricCards(glucoseUnit: glucoseUnit))
                
                TodayQuickActions(
                    addGlucose: { sheetNewGlucoseRecord = true },
                    addInsulin: { sheetNewInsulinRecord = true },
                    addCarbs: { sheetNewCarbsRecord = true },
                    addWeight: { sheetNewWeightRecord = true }
                )
                
                TodayLatestSection {
                    NavigationLink {
                        GlucoseList()
                            .environment(vm)
                    } label: {
                        TodayLatestRow(
                            title: String(localized: "Blood Glucose"),
                            value: latestGlucoseOverall?.formattedValue(in: glucoseUnit),
                            unit: glucoseUnit.title,
                            date: latestGlucoseOverall?.date,
                            icon: "drop",
                            color: .red
                        )
                    }
                    .buttonStyle(.plain)
                    
                    NavigationLink {
                        InsulinList()
                            .environment(vm)
                    } label: {
                        TodayLatestRow(
                            title: String(localized: "Insulin Delivery"),
                            value: latestInsulinOverall?.formattedValue,
                            unit: String(localized: "U"),
                            date: latestInsulinOverall?.date,
                            icon: "syringe",
                            color: .yellow
                        )
                    }
                    .buttonStyle(.plain)
                    
                    NavigationLink {
                        CarbsList()
                            .environment(vm)
                    } label: {
                        TodayLatestRow(
                            title: String(localized: "Carbohydrates"),
                            value: latestCarbsOverall.map { Utils.formatNumber($0.value) },
                            unit: String(localized: "g"),
                            date: latestCarbsOverall?.date,
                            icon: "fork.knife",
                            color: .orange
                        )
                    }
                    .buttonStyle(.plain)
                    
                    NavigationLink {
                        WeightList()
                            .environment(vm)
                    } label: {
                        TodayLatestRow(
                            title: String(localized: "Weight"),
                            value: formattedWeight(latestWeightOverall?.value),
                            unit: String(localized: "kg"),
                            date: latestWeightOverall?.date,
                            icon: "scalemass",
                            color: .blue
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .navigationTitle(Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()))
        .scrollIndicators(.hidden)
        .refreshable {
            await refreshData()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Settings", systemImage: "gear") {
                    showsSettings = true
                }
            }
            
#if canImport(CoreNFC)
            if CoreNFCPenScanner.isReadingAvailable {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Scan Pen", systemImage: "wave.3.right", action: startNovoPenScan)
                        .disabled(novoPenReader.isWorking)
                }
            }
#endif
        }
        .navigationDestination(isPresented: $showsSettings) {
            AppSettings()
        }
        .navigationDestination(for: TodayMetricDestination.self) {
            destinationView(for: $0)
        }
        .sheet($sheetNewGlucoseRecord) {
            NewRecordSheet(.glucose)
                .environment(vm)
        }
        .sheet($sheetNewInsulinRecord) {
            NewRecordSheet(.insulin)
                .environment(vm)
        }
        .sheet($sheetNewCarbsRecord) {
            NewRecordSheet(.carbs)
                .environment(vm)
        }
        .sheet($sheetNewWeightRecord) {
            NavigationStack {
                LogWeightSheet()
            }
                .environment(vm)
        }
#if canImport(CoreNFC)
        .sheet(isPresented: $showsNovoPenWriteConfirmation, onDismiss: novoPenWriteConfirmation.dismiss) {
            NavigationStack {
                NovoPenWriteConfirmationSheet(
                    vm: novoPenWriteConfirmation,
                    healthKit: vm
                )
            }
        }
        .sheet(item: $scannedPenToSave) { reading in
            NavigationStack {
                AddScannedPenSheet(
                    reading: reading,
                    onSaved: { savedPen, shouldPerformFullHistoryScan in
                        if shouldPerformFullHistoryScan {
                            startNovoPenScan(receivesFullHistory: true)
                            return
                        }
                        
                        presentNovoPenWriteConfirmation(for: savedPen)
                    }
                )
            }
        }
        .alert("NovoPen Scan Failed", isPresented: $showsNovoPenScanError) {
            Button("OK") {
                novoPenScanErrorMessage = nil
            }
        } message: {
            if let novoPenScanErrorMessage {
                Text(novoPenScanErrorMessage)
            }
        }
#endif
#if canImport(CoreNFC)
        .onChange(of: novoPenScanRequest) { oldValue, newValue in
            guard newValue > oldValue else {
                return
            }
            
            startNovoPenScan()
        }
        .onChange(of: novoPenReader.status) { oldValue, newValue in
            guard oldValue != newValue else {
                return
            }
            
            handleNovoPenStatusChange(newValue)
        }
#endif
        .task {
            vm.authorize { result in
                Logger().info("Auth status: \(result)")
            }
            
            await refreshData()
        }
    }
    
    private var glucoseToday: [Glucose] {
        vm.glucoseRecords.filter { Calendar.current.isDateInToday($0.date) }
    }
    
    private var insulinToday: [Insulin] {
        vm.insulinRecords.filter { Calendar.current.isDateInToday($0.date) }
    }
    
    private var carbsToday: [Carbs] {
        vm.carbsRecords.filter { Calendar.current.isDateInToday($0.date) }
    }
    
    private var latestGlucoseToday: Glucose? {
        glucoseToday.first
    }
    
    private var latestGlucoseOverall: Glucose? {
        vm.glucoseRecords.first
    }
    
    private var latestInsulinOverall: Insulin? {
        vm.insulinRecords.first
    }
    
    private var latestCarbsOverall: Carbs? {
        vm.carbsRecords.first
    }
    
    private var latestWeightOverall: Weight? {
        vm.weightRecords.first
    }
    
    private var insulinTotal: Double? {
        sumValue(insulinToday.map(\.value))
    }
    
    private var carbsTotal: Double? {
        sumValue(carbsToday.map(\.value))
    }
    
    private func metricCards(glucoseUnit: GlucoseUnit) -> [TodayMetricData] {
        [
            TodayMetricData(
                destination: .glucose,
                title: String(localized: "Glucose"),
                value: formattedGlucose(latestGlucoseToday, in: glucoseUnit),
                unit: glucoseUnit.title,
                icon: "drop",
                color: .red
            ),
            TodayMetricData(
                destination: .carbs,
                title: String(localized: "Carbs"),
                value: formattedNumber(carbsTotal),
                unit: String(localized: "g"),
                icon: "fork.knife",
                color: .orange
            ),
            TodayMetricData(
                destination: .insulin,
                title: String(localized: "Insulin"),
                value: formattedNumber(insulinTotal),
                unit: String(localized: "U"),
                icon: "syringe",
                color: .yellow
            ),
            TodayMetricData(
                destination: .weight,
                title: String(localized: "Weight"),
                value: formattedWeight(latestWeightOverall?.value),
                unit: String(localized: "kg"),
                icon: "scalemass",
                color: .blue
            )
        ]
    }
    
    private func sumValue(_ values: [Double]) -> Double? {
        guard !values.isEmpty else { return nil }
        
        return values.reduce(0, +)
    }
    
    private func formattedNumber(_ value: Double?) -> String {
        guard let value else { return "-" }
        
        return Utils.formatNumber(value)
    }
    
    private func formattedGlucose(_ record: Glucose?, in glucoseUnit: GlucoseUnit) -> String {
        guard let record else { return "-" }
        
        return record.formattedValue(in: glucoseUnit)
    }
    
    private func formattedWeight(_ value: Double?) -> String {
        guard let value else { return "-" }
        
        return value.formatted(.number.precision(.fractionLength(1)))
    }
    
    @ViewBuilder
    private func destinationView(for destination: TodayMetricDestination) -> some View {
        switch destination {
        case .glucose:
            GlucoseList()
                .environment(vm)
            
        case .carbs:
            CarbsList()
                .environment(vm)
            
        case .insulin:
            InsulinList()
                .environment(vm)
            
        case .weight:
            WeightList()
                .environment(vm)
        }
    }
    
    private func refreshData() async {
        await vm.reloadAllRecords()
    }
    
#if canImport(CoreNFC)
    private func startNovoPenScan() {
        startNovoPenScan(receivesFullHistory: false)
    }
    
    private func startNovoPenScan(receivesFullHistory: Bool) {
        novoPenReader.readerOptions.receivesFullHistory = receivesFullHistory
        novoPenReader.startScan()
    }
    
    private func handleNovoPenStatusChange(_ status: ReaderStatus) {
        switch status {
        case .finished:
            guard let reading = novoPenReader.reading else {
                return
            }
            
            if let savedPen = savedPens.first(where: { $0.matches(reading) }) {
                presentNovoPenWriteConfirmation(for: savedPen)
            } else {
                scannedPenToSave = reading
            }
            
        case .failed:
            novoPenScanErrorMessage = novoPenReader.errorMessage ?? String(localized: "An unknown error occurred")
            showsNovoPenScanError = true
            
        case .idle, .scanning, .loadingSample:
            break
        }
    }
    
    private func presentNovoPenWriteConfirmation(for savedPen: SavedPen) {
        let airshotFilter = store.airshotFilter

        Task {
            let insulinRecords = (try? await vm.reloadInsulinRecords()) ?? vm.insulinRecords
            let missingDoses = novoPenReader.missingDoses(
                using: insulinRecords,
                airshotFilter: airshotFilter
            )
            
            novoPenWriteConfirmation.present(
                doses: missingDoses,
                insulinType: savedPen.insulinType,
                penTitle: savedPen.title
            )
            showsNovoPenWriteConfirmation = true
        }
    }
#endif
}

#Preview {
    NavigationStack {
        TodayView(novoPenScanRequest: 0)
    }
    .darkSchemePreferred()
    .environmentObject(ValueStore())
#if canImport(CoreNFC)
    .modelContainer(for: [SavedPen.self], inMemory: true)
#endif
}
