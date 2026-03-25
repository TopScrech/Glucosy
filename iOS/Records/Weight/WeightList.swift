import ScrechKit

struct WeightList: View {
    @Environment(HealthKit.self) private var vm
    
    @State private var sheetNewEntry = false
    
    var body: some View {
        let dayChunks = vm.weightRecords.chunked { lhs, rhs in
            Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
        }
        
        List {
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
        .sheet($sheetNewEntry) {
            NavigationStack {
                LogWeightSheet()
            }
        }
        .toolbar {
            SFButton("note.text.badge.plus") {
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
