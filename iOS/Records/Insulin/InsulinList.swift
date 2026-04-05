import ScrechKit

struct InsulinList: View {
    @Environment(HealthKit.self) private var vm
    
    @State private var sheetNewRecord = false
    
    var body: some View {
        let dayChunks = vm.insulinRecords.chunked { lhs, rhs in
            Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
        }
        
        List {
            Section {
                InsulinChartView(records: vm.insulinRecords)
                    .listRowInsets(.init())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }

            ForEach(dayChunks.indices, id: \.self) { index in
                let chunk = dayChunks[index]
                
                if let first = chunk.first {
                    Section(Utils.formattedDate(first.date)) {
                        ForEach(chunk.reversed()) { record in
                            InsulinCard(record)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button("Delete", systemImage: "trash", role: .destructive) {
                                        vm.deleteInsulin(record)
                                    }
                                }
                        }
                    }
                }
            }
        }
        .navigationTitle("Insulin Delivery")
        .refreshable {
            _ = try? await vm.reloadInsulinRecords()
        }
        .sheet($sheetNewRecord) {
            NewRecordSheet(.insulin)
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
        InsulinList()
    }
    .darkSchemePreferred()
    .environment(HealthKit())
}
