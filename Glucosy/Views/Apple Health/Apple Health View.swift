import SwiftUI

struct AppleHealthView: View {
    @Environment(AppState.self) private var app
    @Environment(History.self)  private var history
    
    @AppStorage("is_expanded_glucose") private var isExpandedGlucose = false
    @AppStorage("is_expanded_insulin") private var isExpandedInsulin = false
    @AppStorage("is_expanded_carbs")   private var isExpandedCarbs = false
    
    var body: some View {
        List {
            HealthKitLink()
            
            Section {
                DisclosureGroup("Glucose", isExpanded: $isExpandedGlucose) {
                    ForEach(history.healthKitGlucose, id: \.self) { glucose in
                        HealthKitCard(glucose)
                    }
                    .onDelete(perform: deleteGlucose)
                }
            } header: {
                HStack {
                    Text("\(history.healthKitGlucose.count) records")
                        .bold()
                    
                    Spacer()
                    
                    NavigationLink("View all") {
                        
                    }
                    .footnote()
                    .foregroundStyle(.latte)
                }
            }
            
            Section {
                DisclosureGroup("Insulin Delivery", isExpanded: $isExpandedInsulin) {
                    ForEach(history.insulinDeliveries, id: \.self) { insulin in
                        InsulinDeliveryCard(insulin)
                    }
                    .onDelete(perform: deleteInsulin)
                }
            } header: {
                HStack {
                    Text("\(history.insulinDeliveries.count) records")
                        .bold()
                    
                    Spacer()
                    
                    NavigationLink("View all") {
                        
                    }
                    .footnote()
                    .foregroundStyle(.latte)
                }
            }
            
            Section {
                DisclosureGroup("Carbohydrates", isExpanded: $isExpandedCarbs) {
                    ForEach(history.consumedCarbohydrates, id: \.self) { carbs in
                        CarbohydratesCard(carbs)
                    }
                    .onDelete(perform: deleteCarbs)
                }
            } header: {
                HStack {
                    Text("\(history.consumedCarbohydrates.count) records")
                        .bold()
                    
                    Spacer()
                    
                    NavigationLink("View all") {
                        
                    }
                    .footnote()
                    .foregroundStyle(.latte)
                }
            }
        }
        .refreshableTask {
            if let healthKit = app.main?.healthKit {
                healthKit.readGlucose()
                healthKit.readInsulin()
                healthKit.readCarbs()
            }
        }
        .toolbar {
            Button("New record") {
                app.sheetMealtime = true
            }
            .tint(.green)
        }
    }
    
    private func deleteInsulin(_ offsets: IndexSet) {
        offsets.forEach { index in
            guard let sampleToDelete = history.insulinDeliveries[index].sample else {
                return
            }
            
            app.main.healthKit?.delete(sampleToDelete) { success, error in
                if success {
                    Task { @MainActor in
                        history.insulinDeliveries.remove(atOffsets: offsets)
                    }
                } else if let error {
                    print("Error deleting from HealthKit: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func deleteCarbs(_ offsets: IndexSet) {
        offsets.forEach { index in
            guard let sampleToDelete = history.consumedCarbohydrates[index].sample else {
                return
            }
            
            app.main.healthKit?.delete(sampleToDelete) { success, error in
                if success {
                    Task { @MainActor in
                        history.consumedCarbohydrates.remove(atOffsets: offsets)
                    }
                } else if let error {
                    print("Error deleting from HealthKit: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func deleteGlucose(_ offsets: IndexSet) {
        offsets.forEach { index in
            guard let sampleToDelete = history.healthKitGlucose[index].sample else {
                return
            }
            
            app.main.healthKit?.delete(sampleToDelete) { success, error in
                if success {
                    Task { @MainActor in
                        history.healthKitGlucose.remove(atOffsets: offsets)
                    }
                } else if let error {
                    print("Error deleting glucose: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .glucosyPreview(.healthKit)
}
