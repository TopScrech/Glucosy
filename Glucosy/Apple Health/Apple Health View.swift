import ScrechKit

struct AppleHealthView: View {
    @Environment(AppState.self) private var app
    @Environment(History.self)  private var history
    @Environment(Settings.self) private var settings
    
    @AppStorage("is_expanded_glucose")     private var isExpandedGlucose = false
    @AppStorage("is_expanded_insulin")     private var isExpandedInsulin = false
    @AppStorage("is_expanded_carbs")       private var isExpandedCarbs = false
    @AppStorage("is_expanded_temperature") private var isExpandedTemperature = false
    
    var body: some View {
        List {
            HealthKitLink()
            
            GlycatedHaemoglobinView(history.glucose)
            
            Section {
                NavigationLink {
                    GlucoseList(history.glucose)
                } label: {
                    HStack(alignment: .bottom) {
                        Text("Glucose")
                        
                        Spacer()
                        
                        Text(history.glucose.first?.value ?? 0)
                            .bold()
                        
                        Text(settings.displayingMillimoles ? "mmol/L" : "mg/dL")
                            .foregroundStyle(.secondary)
                            .footnote()
                    }
                }
            } header: {
                Text("\(history.glucose.count) records")
                    .bold()
            }
            
            if let lastDelivery = history.insulin.first {
                Section {
                    NavigationLink {
                        InsulinList(history.insulin)
                    } label: {
                        HStack(alignment: .bottom) {
                            Text("Insulin Delivery")
                            
                            Spacer()
                            
                            Text(lastDelivery.value)
                                .bold()
                            
                            if lastDelivery.type == .bolus {
                                Image(systemName: "syringe")
                                    .foregroundStyle(.yellow)
                            } else {
                                Image(systemName: "syringe.fill")
                                    .foregroundStyle(.purple)
                            }
                        }
                    }
                } header: {
                    Text("\(history.insulin.count) records")
                        .bold()
                }
            }
            
            Section {
                DisclosureGroup("Carbohydrates", isExpanded: $isExpandedCarbs) {
                    ForEach(history.carbs, id: \.self) { carbs in
                        CarbohydratesCard(carbs)
                    }
                    .onDelete(perform: deleteCarbs)
                }
            } header: {
                HStack {
                    Text("\(history.carbs.count) records")
                        .bold()
                    
                    Spacer()
                    
                    NavigationLink("View all") {
                        // TODO
                    }
                    .footnote()
                    .foregroundStyle(.latte)
                }
            }
        }
        .standardToolbar()
        .refreshableTask {
            if let healthKit = app.main?.healthKit {
                healthKit.readGlucose()
                healthKit.readInsulin()
                healthKit.readCarbs()
            }
        }
    }
        
    private func deleteCarbs(_ offsets: IndexSet) {
        offsets.forEach { index in
            guard let sampleToDelete = history.carbs[index].sample else {
                return
            }
            
            app.main.healthKit?.delete(sampleToDelete) { success, error in
                if success {
                    Task { @MainActor in
                        history.carbs.remove(atOffsets: offsets)
                    }
                } else if let error {
                    print("Error deleting from HealthKit: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .glucosyPreview(.healthKit)
}
