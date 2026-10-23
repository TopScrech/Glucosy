import ScrechKit

struct WeightRecordList: View {
    @Environment(HealthKit.self) private var vm
    
    @State private var sheetNewEntry = false
    
    var body: some View {
        List {
            Section {
                WeightChart(vm.weightRecords)
                    .listRowInsets(.init())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            
            ForEach(vm.weightDays) { day in
                Section(Utils.formattedDate(day.date)) {
                    ForEach(day.records) {
                        WeightRecordCard($0)
                    }
                }
            }
        }
        .navigationTitle("Weight")
        .task {
            _ = try? await vm.reloadWeightRecords(fullHistory: true, ifStale: true)
        }
        .refreshable {
            _ = try? await vm.reloadWeightRecords(fullHistory: true)
        }
        .sheet($sheetNewEntry) {
            NewRecordSheet(.weight)
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
        WeightRecordList()
    }
    .darkSchemePreferred()
    .environment(HealthKit())
}
