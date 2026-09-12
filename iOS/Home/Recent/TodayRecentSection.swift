import HealthKit
import ScrechKit

struct TodayRecentSection: View {
    @Environment(HealthKit.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        let glucoseUnit = store.glucoseUnit
        let entries = recentEntries(in: glucoseUnit)
        
        if !entries.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent")
                    .title3(.semibold, design: .rounded)
                
                VStack(spacing: 12) {
                    ForEach(entries) { entry in
                        NavigationLink {
                            destination(for: entry.destination)
                        } label: {
                            TodayRecentRow(
                                title: entry.title,
                                value: entry.value,
                                unit: entry.unit,
                                date: entry.date,
                                icon: entry.icon,
                                color: entry.color
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    private var recentCutoff: Date {
        Date.now.addingTimeInterval(-15 * 60)
    }
    
    private var recentGlucoseRecords: [Glucose] {
        vm.glucoseRecords.filter { $0.date >= recentCutoff }
    }
    
    private var recentInsulinRecords: [Insulin] {
        vm.insulinRecords.filter { $0.date >= recentCutoff }
    }
    
    private var recentCarbsRecords: [Carbs] {
        vm.carbsRecords.filter { $0.date >= recentCutoff }
    }
    
    private var recentWeightRecords: [Weight] {
        vm.weightRecords.filter { $0.date >= recentCutoff }
    }
    
    private var recentBMIRecords: [BMI] {
        vm.bmiRecords.filter { $0.date >= recentCutoff }
    }
    
    private func recentEntries(in glucoseUnit: GlucoseUnit) -> [TodayRecentEntry] {
        var entries: [TodayRecentEntry] = []
        
        if let glucoseEntry = recentGlucoseEntry(in: glucoseUnit) {
            entries.append(glucoseEntry)
        }
        
        entries.append(contentsOf: recentInsulinRecords.map {
            TodayRecentEntry(
                id: $0.sample.uuid.uuidString,
                destination: .insulin,
                title: "Insulin Delivery",
                value: $0.formattedValue,
                unit: String(localized: "U"),
                date: $0.date,
                icon: $0.icon,
                color: $0.color
            )
        })
        
        entries.append(contentsOf: recentCarbsRecords.map {
            TodayRecentEntry(
                id: $0.sample.uuid.uuidString,
                destination: .carbs,
                title: "Carbohydrates",
                value: Utils.formatNumber($0.value),
                unit: String(localized: "g"),
                date: $0.date,
                icon: "fork.knife",
                color: .orange
            )
        })
        
        entries.append(contentsOf: recentWeightRecords.map {
            TodayRecentEntry(
                id: $0.sample.uuid.uuidString,
                destination: .weight,
                title: "Weight",
                value: Utils.formatTenths($0.value),
                unit: String(localized: "kg"),
                date: $0.date,
                icon: "scalemass",
                color: .blue
            )
        })
        
        entries.append(contentsOf: recentBMIRecords.map {
            TodayRecentEntry(
                id: $0.sample.uuid.uuidString,
                destination: .bmi,
                title: "Body Mass Index",
                value: Utils.formatTenths($0.value),
                unit: nil,
                date: $0.date,
                icon: "figure",
                color: .mint
            )
        })
        
        return entries.sorted { $0.date > $1.date }
    }
    
    private func recentGlucoseEntry(in unit: GlucoseUnit) -> TodayRecentEntry? {
        guard let latestGlucoseRecord = recentGlucoseRecords.first else {
            return nil
        }
        
        return TodayRecentEntry(
            id: "glucose-range",
            destination: .glucose,
            title: "Blood Glucose",
            value: glucoseRange(in: unit),
            unit: unit.title,
            date: latestGlucoseRecord.date,
            icon: "drop",
            color: .red
        )
    }
    
    private func glucoseRange(in unit: GlucoseUnit) -> String? {
        let values = recentGlucoseRecords.map(\.value)
        
        guard
            let minimum = values.min(),
            let maximum = values.max()
        else {
            return nil
        }
        
        let minimumValue = unit.formattedValue(fromMilligramsPerDeciliter: minimum)
        let maximumValue = unit.formattedValue(fromMilligramsPerDeciliter: maximum)
        
        guard minimumValue != maximumValue else {
            return minimumValue
        }
        
        return "\(minimumValue)-\(maximumValue)"
    }
    
    @ViewBuilder
    private func destination(for destination: TodayMetricDestination) -> some View {
        switch destination {
        case .glucose:
            GlucoseRecordList()
                .environment(vm)
            
        case .carbs:
            CarbsRecordList()
                .environment(vm)
            
        case .insulin:
            InsulinRecordList(onScanPen: nil)
                .environment(vm)
            
        case .weight:
            WeightRecordList()
                .environment(vm)
            
        case .activeEnergy:
            EnergyHistoryView(kind: .active)
                .environment(vm)
        case .dietaryEnergy:
            EnergyHistoryView(kind: .dietary)
                .environment(vm)
        case .bmi:
            BMIRecordList()
                .environment(vm)
        }
    }
    
}

#Preview {
    TodayRecentSection()
        .padding()
        .darkSchemePreferred()
}
