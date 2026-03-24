import SwiftUI
import OSLog

struct TodayView: View {
    @State private var vm = HealthKit()
    
    @State private var sheetNewInsulinRecord = false
    @State private var sheetNewCarbsRecord = false
    @State private var sheetNewGlucoseRecord = false
    @State private var sheetNewWeightRecord = false
    
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
        .navigationTitle("Today")
        .toolbar {
            Menu {
                Button("Carbohydrates", systemImage: "fork.knife") {
                    sheetNewCarbsRecord = true
                }
                
                Button("Insulin Delivery", systemImage: "syringe") {
                    sheetNewInsulinRecord = true
                }
                
                Button("Blood Glucose", systemImage: "drop") {
                    sheetNewGlucoseRecord = true
                }
                
                Button("Weight", systemImage: "scalemass") {
                    sheetNewWeightRecord = true
                }
            } label: {
                Image(systemName: "note.text.badge.plus")
            }
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
    
    private var latestInsulinToday: Insulin? {
        insulinToday.first
    }
    
    private var latestCarbsToday: Carbs? {
        carbsToday.first
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
    
    private var glucoseAverage: Double? {
        averageValue(glucoseToday.map(\.value))
    }
    
    private var insulinTotal: Double? {
        sumValue(insulinToday.map(\.value))
    }
    
    private var insulinBasalTotal: Double? {
        sumValue(insulinToday.filter { $0.type == .basal }.map(\.value))
    }
    
    private var insulinBolusTotal: Double? {
        sumValue(insulinToday.filter { $0.type == .bolus }.map(\.value))
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
                id: "glucose",
                title: String(localized: "Glucose"),
                value: formattedNumber(latestGlucoseToday?.value),
                unit: String(localized: "mg/dL"),
                subtitle: glucoseSubtitle,
                icon: "drop",
                color: .red
            ),
            TodayMetricData(
                id: "carbs",
                title: String(localized: "Carbs"),
                value: formattedNumber(carbsTotal),
                unit: String(localized: "g"),
                subtitle: carbsSubtitle,
                icon: "fork.knife",
                color: .orange
            ),
            TodayMetricData(
                id: "insulin",
                title: String(localized: "Insulin"),
                value: formattedNumber(insulinTotal),
                unit: String(localized: "U"),
                subtitle: insulinSubtitle,
                icon: "syringe",
                color: .yellow
            ),
            TodayMetricData(
                id: "weight",
                title: String(localized: "Weight"),
                value: formattedWeight(latestWeightOverall?.value),
                unit: String(localized: "kg"),
                subtitle: weightSubtitle,
                icon: "scalemass",
                color: .blue
            )
        ]
    }
    
    private var glucoseSubtitle: String {
        if let glucoseAverage {
            String(localized: "Avg \(Utils.formatNumber(glucoseAverage)) mg/dL")
        } else {
            String(localized: "No readings today")
        }
    }
    
    private var carbsSubtitle: String {
        if let latestCarbsToday {
            String(localized: "Last \(formattedTime(latestCarbsToday.date))")
        } else {
            String(localized: "No carbs today")
        }
    }
    
    private var insulinSubtitle: String {
        var parts: [String] = []
        
        if let insulinBasalTotal {
            parts.append(String(localized: "Basal \(Utils.formatNumber(insulinBasalTotal)) U"))
        }
        
        if let insulinBolusTotal {
            parts.append(String(localized: "Bolus \(Utils.formatNumber(insulinBolusTotal)) U"))
        }
        
        return parts.isEmpty ? String(localized: "No insulin today") : parts.joined(separator: ", ")
    }
    
    private var weightSubtitle: String {
        if let latestWeightOverall {
            String(localized: "Last \(Utils.formattedDate(latestWeightOverall.date))")
        } else {
            String(localized: "No weight data")
        }
    }
    
    private func sumValue(_ values: [Double]) -> Double? {
        guard !values.isEmpty else { return nil }
        
        return values.reduce(0, +)
    }
    
    private func averageValue(_ values: [Double]) -> Double? {
        guard let total = sumValue(values) else { return nil }
        
        return total / Double(values.count)
    }
    
    private func formattedNumber(_ value: Double?) -> String {
        guard let value else { return "--" }
        
        return Utils.formatNumber(value)
    }
    
    private func formattedWeight(_ value: Double?) -> String {
        guard let value else { return "--" }
        
        return value.formatted(.number.precision(.fractionLength(1)))
    }
    
    private func formattedTime(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }
    
    private func refreshData() {
        vm.readGlucose()
        vm.readInsulin()
        vm.readCarbs()
        vm.readWeight()
    }
}

#Preview {
    NavigationStack {
        TodayView()
    }
    .darkSchemePreferred()
}
