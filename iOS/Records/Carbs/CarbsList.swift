import ScrechKit

struct CarbsList: View {
    @Environment(HealthKit.self) private var vm
    
    @State private var sheetNewRecord = false
    
    var body: some View {
        let dayChunks = vm.carbsRecords.chunked { lhs, rhs in
            Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
        }
        
        List {
            ForEach(dayChunks.indices, id: \.self) { index in
                let chunk = dayChunks[index]
                
                if let first = chunk.first {
                    Section(Utils.formattedDate(first.date)) {
                        ForEach(chunk.reversed()) { record in
                            CarbsCard(record)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button("Delete", systemImage: "trash", role: .destructive) {
                                        vm.deleteCarbs(record)
                                    }
                                }
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
            SFButton("note.text.badge.plus") {
                sheetNewRecord = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        CarbsList()
    }
    .darkSchemePreferred()
    .environment(HealthKit())
}
