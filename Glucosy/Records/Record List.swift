import ScrechKit

struct RecordList: View {
    @State private var vm = HealthKit()
    
    @State private var sheetNewInsulinRecord = false
    @State private var sheetNewCarbsRecord = false
    @State private var sheetNewGlucoseRecord = false
    
    var body: some View {
        List {
            Section {
                Text("Estimated HbA1c")
            }
            
            Section {
                NavigationLink("Glucose") {
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
                    NewRecordSheet()
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
                    NewRecordSheet()
                }
            }
            
            Section {
                NavigationLink("Carbs") {
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
                    NewRecordSheet()
                }
            }
        }
        .toolbar {
            SFButton("note.text.badge.plus") {
                
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
