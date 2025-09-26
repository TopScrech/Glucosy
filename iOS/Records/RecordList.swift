import ScrechKit

struct RecordList: View {
    @State private var vm = HealthKit()
    
    @State private var sheetNewInsulinRecord = false
    @State private var sheetNewCarbsRecord = false
    @State private var sheetNewGlucoseRecord = false
    @State private var sheetNewWeightRecord = false
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Estimated HbA1c")
                    
                    Spacer()
                    
                    Text("Unknown")
                        .secondary()
                }
            }
            
            Section {
                NavigationLink("Blood Glucose") {
                    GlucoseList()
                        .environment(vm)
                }
                .contextMenu {
                    Button("New record", systemImage: "plus") {
                        sheetNewGlucoseRecord = true
                    }
                }
                .sheet($sheetNewGlucoseRecord) {
                    NewRecordSheet(.glucose)
                }
            }
            
            Section {
                NavigationLink("Insulin Delivery") {
                    InsulinList()
                        .environment(vm)
                }
                .contextMenu {
                    Button("New record", systemImage: "plus") {
                        sheetNewInsulinRecord = true
                    }
                }
                .sheet($sheetNewInsulinRecord) {
                    NewRecordSheet(.insulin)
                }
            }
            
            Section {
                NavigationLink("Carbohydrates") {
                    CarbsList()
                        .environment(vm)
                }
                .contextMenu {
                    Button("New record", systemImage: "plus") {
                        sheetNewCarbsRecord = true
                    }
                }
                .sheet($sheetNewCarbsRecord) {
                    NewRecordSheet(.carbs)
                }
            }
            
            Section {
                NavigationLink("Weight") {
                    WeightList()
                        .environment(vm)
                }
                .contextMenu {
                    Button("New record", systemImage: "plus") {
                        sheetNewWeightRecord = true
                    }
                }
                .sheet($sheetNewWeightRecord) {
                    LogWeightSheet()
                }
            }
        }
        .task {
            vm.authorize { result in
                print("Auth status:", result)
                
                // TODO: Display Warning when false
            }
            
            vm.readGlucose()
            vm.readInsulin()
            vm.readCarbs()
        }
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
            } label: {
                Image(systemName: "note.text.badge.plus")
            }
        }
    }
}

#Preview {
    RecordList()
        .darkSchemePreferred()
}
