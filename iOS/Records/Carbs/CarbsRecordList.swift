import ScrechKit

struct CarbsRecordList: View {
    @Environment(HealthKit.self) private var vm
    
    @State private var sheetNewRecord = false
    
    var body: some View {
        List {
            Section {
                CarbsChart(vm.carbsRecords)
                    .listRowInsets(.init())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            
            ForEach(vm.carbsDays) { day in
                Section(Utils.formattedDate(day.date)) {
                    ForEach(day.records) {
                        CarbsRecordCard($0)
                    }
                }
            }
        }
        .navigationTitle("Carbohydrates")
        .task {
            _ = try? await vm.reloadCarbsRecords(fullHistory: true, ifStale: true)
        }
        .refreshable {
            _ = try? await vm.reloadCarbsRecords(fullHistory: true)
        }
        .sheet($sheetNewRecord) {
            NewRecordSheet(.carbs)
                .environment(vm)
        }
        .toolbar {
            SFButton("plus") {
                sheetNewRecord = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        CarbsRecordList()
    }
    .darkSchemePreferred()
    .environment(HealthKit())
}
