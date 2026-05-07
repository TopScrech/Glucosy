import ScrechKit
import Algorithms

struct CarbsRecordList: View {
    @Environment(HealthKit.self) private var vm
    
    @State private var sheetNewRecord = false
    
    var body: some View {
        let dayChunks = vm.carbsRecords.chunked { lhs, rhs in
            Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
        }
        
        List {
            Section {
                CarbsChart(vm.carbsRecords)
                    .listRowInsets(.init())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            
            ForEach(dayChunks.indices, id: \.self) { index in
                let chunk = dayChunks[index]
                
                if let first = chunk.first {
                    Section(Utils.formattedDate(first.date)) {
                        ForEach(chunk) {
                            CarbsRecordCard($0)
                        }
                    }
                }
            }
        }
        .navigationTitle("Carbohydrates")
        .refreshable {
            _ = try? await vm.reloadCarbsRecords()
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
