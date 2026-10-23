import ScrechKit

struct GlucoseRecordList: View {
    @Environment(HealthKit.self) private var vm
    
    @State private var sheetNewRecord = false
    
    var body: some View {
        List {
            Section {
                GlucoseChart(vm.glucoseRecords)
                    .listRowInsets(.init())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            
            ForEach(vm.glucoseDays) { day in
                Section(Utils.formattedDate(day.date)) {
                    ForEach(day.records) {
                        GlucoseRecordCard($0)
                    }
                }
            }
        }
        .navigationTitle("Blood Glucose")
        .task {
            _ = try? await vm.reloadGlucoseRecords(fullHistory: true, ifStale: true)
        }
        .refreshable {
            _ = try? await vm.reloadGlucoseRecords(fullHistory: true)
        }
        .sheet($sheetNewRecord) {
            NewRecordSheet(.glucose)
                .environment(vm)
                .presentationDetents([.medium])
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
        GlucoseRecordList()
    }
    .darkSchemePreferred()
    .environment(HealthKit())
}
