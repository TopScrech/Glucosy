import ScrechKit

struct WeightList: View {
    @Environment(HealthKit.self) private var vm
    
    @State private var sheetNewEntry = false
    
    var body: some View {
        let dayChunks = vm.weightRecords.chunked { lhs, rhs in
            Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
        }
        
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(dayChunks.indices, id: \.self) { index in
                    let chunk = dayChunks[index]
                    
                    if let first = chunk.first {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(Utils.formattedDate(first.date))
                                .title3(.semibold, design: .rounded)
                                .padding(.horizontal)
                            
                            LazyVGrid(
                                columns: [
                                    GridItem(
                                        .adaptive(minimum: 60),
                                        spacing: 0
                                    )
                                ],
                                spacing: 12
                            ) {
                                ForEach(chunk.reversed()) {
                                    WeightCard($0)
                                }
                            }
                            .padding(.horizontal)
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
