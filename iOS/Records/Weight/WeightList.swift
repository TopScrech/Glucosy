import ScrechKit
import Algorithms

struct WeightList: View {
    @Environment(HealthKit.self) private var vm
    
    @State private var sheetNewEntry = false
    
    var body: some View {
        let dayChunks = vm.weightRecords.chunked { lhs, rhs in
            Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
        }
        
        List {
            Section {
                WeightChartView(records: vm.weightRecords)
                    .listRowInsets(.init())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            
            ForEach(dayChunks.indices, id: \.self) { index in
                let chunk = dayChunks[index]
                
                if let first = chunk.first {
                    Section(Utils.formattedDate(first.date)) {
                        ForEach(chunk.reversed()) {
                            WeightCard($0)
                        }
                    }
                }
            }
        }
        .navigationTitle("Weight")
        .refreshable {
            _ = try? await vm.reloadWeightRecords()
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
        WeightList()
    }
    .darkSchemePreferred()
    .environment(HealthKit())
}
