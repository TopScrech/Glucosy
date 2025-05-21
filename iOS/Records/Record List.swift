import ScrechKit

struct RecordList: View {
    @State private var vm = HealthKit()
    
    @State private var sheetNewInsulinRecord = false
    @State private var sheetNewCarbsRecord = false
    @State private var sheetNewGlucoseRecord = false
    
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
                    Button {
                        sheetNewGlucoseRecord = true
                    } label: {
                        Label("New record", systemImage: "plus")
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
                    Button {
                        sheetNewInsulinRecord = true
                    } label: {
                        Label("New record", systemImage: "plus")
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
                    Button {
                        sheetNewCarbsRecord = true
                    } label: {
                        Label("New record", systemImage: "plus")
                    }
                }
                .sheet($sheetNewCarbsRecord) {
                    NewRecordSheet(.carbs)
                }
            }
        }
        .toolbar {
            Menu {
                Button {
                    sheetNewCarbsRecord = true
                } label: {
                    Label("Carbohydrates", systemImage: "fork.knife")
                }
                
                Button {
                    sheetNewInsulinRecord = true
                    
                } label: {
                    Label("Insulin Delivery", systemImage: "syringe")
                }
                
                Button {
                    sheetNewGlucoseRecord = true
                } label: {
                    Label("Blood Glucose", systemImage: "drop")
                }
            } label: {
                Image(systemName: "note.text.badge.plus")
            }
        }
        .task {
            vm.authorize { result in
                print("Auth status: \(result)")
                
                // TODO: Display Warning when false
            }
            
            vm.readGlucose()
            vm.readInsulin()
            vm.readCarbs()
        }
    }
}

#Preview {
    RecordList()
}
