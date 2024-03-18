import SwiftUI

struct AppleHealthView: View {
    @Environment(AppState.self) private var app
    @Environment(History.self) private var history
    
    @AppStorage("is_expanded_glucose") private var isExpandedGlucose = false
    @AppStorage("is_expanded_insulin") private var isExpandedInsulin = false
    @AppStorage("is_expanded_carbs") private var isExpandedCarbs = false
    
    var body: some View {
        List {
            HealthKitLink()
            
            Section {
                DisclosureGroup("Glucose", isExpanded: $isExpandedGlucose) {
                    ForEach(history.storedValues) { glucose in
                        HealthKitCard(glucose)
                    }
                }
            } header: {
                Text("\(history.storedValues.count) records")
                    .bold()
            }
            
            Section {
                DisclosureGroup("Insulin Delivery", isExpanded: $isExpandedInsulin) {
                    ForEach(history.insulinDeliveries, id: \.self) { insulin in
                        InsulinDeliveryCard(insulin)
                    }
                }
            } header: {
                Text("\(history.insulinDeliveries.count) records")
                    .bold()
            }
            
            Section {
                DisclosureGroup("Carbohydrates", isExpanded: $isExpandedCarbs) {
                    ForEach(history.consumedCarbohydrates, id: \.self) { carbs in
                        CarbohydratesCard(carbs)
                    }
                }
            } header: {
                Text("\(history.consumedCarbohydrates.count) records")
                    .bold()
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
}

#Preview {
    HomeView()
        .glucosyPreview(.healthKit)
}
