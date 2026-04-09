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
                        ForEach(chunk.reversed()) { record in
                            WeightCard(record) {
                                vm.deleteWeight(record)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    vm.deleteWeight(record)
                                }
                            }
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
}

#Preview {
    NavigationStack {
        WeightList()
    }
    .darkSchemePreferred()
    .environment(HealthKit())
}
