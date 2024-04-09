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
                        HStack {
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
            
            if let lastCarbs = history.carbs.first {
                Section {
                    NavigationLink {
                        
                    } label: {
                        HStack(alignment: .bottom) {
                            Text("Carbohydrates")
                            
                            Spacer()
                            
                            Text(lastCarbs.value)
                                .bold()
                            
                            Text("grams")
                                .foregroundStyle(.secondary)
                                .footnote()
                        }
                    }
                } header: {
                    Text("\(history.carbs.count) records")
                        .bold()
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
}

#Preview {
    HomeView()
        .glucosyPreview(.healthKit)
}
