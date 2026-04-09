import ScrechKit
import Algorithms

struct BMIList: View {
    @Environment(HealthKit.self) private var vm
    
    @State private var sheetNewEntry = false
    
    var body: some View {
        let dayChunks = vm.bmiRecords.chunked { lhs, rhs in
            Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
        }
        
        List {
            Section {
                BMIChartView(records: vm.bmiRecords)
                    .listRowInsets(.init())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            
            ForEach(dayChunks.indices, id: \.self) { index in
                let chunk = dayChunks[index]
                
                if let first = chunk.first {
                    Section(Utils.formattedDate(first.date)) {
                        ForEach(chunk.reversed()) {
                            BMICard($0)
                        }
                    }
                }
            }
        }
        .navigationTitle("BMI")
        .refreshable {
            _ = try? await vm.reloadBMIRecords()
        }
        .sheet($sheetNewEntry) {
            NavigationStack {
                LogBMISheet()
                    .environment(vm)
            }
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
        BMIList()
    }
    .darkSchemePreferred()
    .environment(HealthKit())
}
