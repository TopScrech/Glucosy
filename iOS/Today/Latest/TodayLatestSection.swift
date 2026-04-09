import SwiftUI

struct TodayLatestSection: View {
    @Environment(HealthKit.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    var body: some View {
        let glucoseUnit = store.glucoseUnit
        
        VStack(alignment: .leading, spacing: 12) {
            Text("Latest")
                .title3(.semibold, design: .rounded)
            
            VStack(spacing: 12) {
                NavigationLink {
                    GlucoseList()
                        .environment(vm)
                } label: {
                    TodayLatestRow(
                        title: "Blood Glucose",
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
                        title: "Insulin Delivery",
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
                        title: "Carbohydrates",
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
                        title: "Weight",
                        value: formattedWeight(latestWeightOverall?.value),
                        unit: String(localized: "kg"),
                        date: latestWeightOverall?.date,
                        icon: "scalemass",
                        color: .blue
                    )
                }
                .buttonStyle(.plain)
                
                NavigationLink {
                    BMIList()
                        .environment(vm)
                } label: {
                    TodayLatestRow(
                        title: "Body Mass Index",
                        value: formattedBMI(latestBMIOverall?.value),
                        unit: nil,
                        date: latestBMIOverall?.date,
                        icon: "figure",
                        color: .mint
                    )
                }
                .buttonStyle(.plain)
            }
        }
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
    
    private var latestBMIOverall: BMI? {
        vm.bmiRecords.first
    }
    
    private func formattedWeight(_ value: Double?) -> String {
        guard let value else { return "-" }
        
        return value.formatted(.number.precision(.fractionLength(1)))
    }
    
    private func formattedBMI(_ value: Double?) -> String {
        guard let value else { return "-" }
        
        return value.formatted(.number.precision(.fractionLength(1)))
    }
}

#Preview {
    TodayLatestSection()
        .padding()
        .darkSchemePreferred()
}
