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
                        ForEach(chunk.reversed()) { record in
                            WeightCard(record)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    if canDelete(record) {
                                        Button("Delete", systemImage: "trash", role: .destructive) {
                                            vm.deleteWeight(record)
                                        }
                                    }
                                }
                        }
                    }
                }
            }
        }
        .navigationTitle("Weight")
        .sheet($sheetNewEntry) {
            NavigationStack {
                LogWeightSheet()
                    .environment(vm)
            }
        }
        .toolbar {
            SFButton("note.text.badge.plus") {
                sheetNewEntry = true
            }
        }
    }

    private func canDelete(_ record: Weight) -> Bool {
        record.sample.sourceRevision.source.bundleIdentifier == Bundle.main.bundleIdentifier
    }
}

#Preview {
    NavigationStack {
        WeightList()
    }
    .darkSchemePreferred()
    .environment(HealthKit())
}
