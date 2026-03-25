import SwiftUI
import OSLog

struct TodayView: View {
    @State private var vm = HealthKit()
    
    @State private var showsSettings = false
    @State private var sheetNewInsulinRecord = false
    @State private var sheetNewCarbsRecord = false
    @State private var sheetNewGlucoseRecord = false
    @State private var sheetNewWeightRecord = false

    let openNovoPenScan: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                TodayHeader(
                    date: Date(),
                    lastUpdated: lastUpdated
                )
                
                TodayMetricsSection(metrics: metricCards)
                
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
                            value: latestGlucoseOverall.map { Utils.formatNumber($0.value) },
                            unit: String(localized: "mg/dL"),
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
        .scrollIndicators(.never)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Settings", systemImage: "gear") {
                    showsSettings = true
                }
            }
            
            if CoreNFCPenScanner.isReadingAvailable {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Scan Pen", systemImage: "wave.3.right", action: openNovoPenScan)
                }
            }
        }
        .navigationDestination(isPresented: $showsSettings) {
            AppSettings()
        }
        .navigationDestination(for: TodayMetricDestination.self) {
            destinationView(for: $0)
        }
        .sheet($sheetNewGlucoseRecord) {
            NewRecordSheet(.glucose)
        }
        .sheet($sheetNewInsulinRecord) {
            NewRecordSheet(.insulin)
        }
        .sheet($sheetNewCarbsRecord) {
            NewRecordSheet(.carbs)
        }
        .sheet($sheetNewWeightRecord) {
            LogWeightSheet()
                .environment(vm)
        }
        .task {
            vm.authorize { result in
                Logger().info("Auth status: \(result, privacy: .public)")
            }
            
            refreshData()
        }
        .refreshable {
            refreshData()
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
    
    private var lastUpdated: Date? {
        [
            latestGlucoseOverall?.date,
            latestInsulinOverall?.date,
            latestCarbsOverall?.date,
            latestWeightOverall?.date
        ]
            .compactMap { $0 }
            .max()
    }
    
    private var metricCards: [TodayMetricData] {
        [
            TodayMetricData(
                destination: .glucose,
                title: String(localized: "Glucose"),
                value: formattedNumber(latestGlucoseToday?.value),
                unit: String(localized: "mg/dL"),
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
        guard let value else { return "--" }
        
        return Utils.formatNumber(value)
    }
    
    private func formattedWeight(_ value: Double?) -> String {
        guard let value else { return "--" }
        
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
    
    private func refreshData() {
        vm.readGlucose()
        vm.readInsulin()
        vm.readCarbs()
        vm.readWeight()
    }

    init(openNovoPenScan: @escaping () -> Void = {}) {
        self.openNovoPenScan = openNovoPenScan
    }
}

#Preview {
    NavigationStack {
        TodayView()
    }
    .darkSchemePreferred()
}
