import ScrechKit

struct BMIRecordList: View {
    @Environment(HealthKit.self) private var vm
    
    @State private var sheetNewEntry = false
    
    var body: some View {
        List {
            Section {
                BMIChart(vm.bmiRecords)
                    .listRowInsets(.init())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            
            ForEach(vm.bmiDays) { day in
                Section(Utils.formattedDate(day.date)) {
                    ForEach(day.records) {
                        BMIRecordCard($0)
                    }
                }
            }
        }
        .navigationTitle("BMI")
        .task {
            _ = try? await vm.reloadBMIRecords(fullHistory: true, ifStale: true)
        }
        .refreshable {
            _ = try? await vm.reloadBMIRecords(fullHistory: true)
        }
        .sheet($sheetNewEntry) {
            NewRecordSheet(.bmi)
        }
        .toolbar {
            SFButton("plus") {
                sheetNewEntry = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        BMIRecordList()
    }
    .darkSchemePreferred()
    .environment(HealthKit())
}
