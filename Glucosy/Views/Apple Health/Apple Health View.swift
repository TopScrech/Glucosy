import SwiftUI

struct AppleHealthView: View {
    @Environment(AppState.self) private var app
    @Environment(History.self) private var history
    
    var body: some View {
        List {
            HealthKitLink()
            
            Section {
                DisclosureGroup("Glucose") {
                    ForEach(history.storedValues) { glucose in
                        HealthKitCard(glucose)
                    }
                }
            } header: {
                Text("\(history.storedValues.count) records")
                    .bold()
            }
            
            Section {
                DisclosureGroup("Insulin Delivery") {
                    ForEach(history.insulinDeliveries, id: \.self) { insulin in
                        InsulinDeliveryCard(insulin)
                    }
                }
            } header: {
                Text("\(history.insulinDeliveries.count) records")
                    .bold()
            }
            
            Section {
                DisclosureGroup("Carbohydrates") {
                    ForEach(history.consumedCarbohydrates, id: \.self) { carbs in
                        CarbohydratesCard(carbs)
                    }
                }
            } header: {
                Text("\(history.consumedCarbohydrates.count) records")
                    .bold()
            }
        }
        //        .overlay {
        //            if history.storedValues.count > 0 {
        //                ContentUnavailableView("No data found", systemImage: "hammer", description: Text("123"))
        //            }
        //        }
        .refreshableTask {
            if let healthKit = app.main?.healthKit {
                healthKit.readGlucose()
                healthKit.readInsulin()
                healthKit.readCarbs()
            }
        }
    }
}

#Preview {
    AppleHealthView()
        .environment(AppState())
        .environment(History.test)
}
