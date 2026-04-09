import ScrechKit
import Algorithms

struct GlucoseList: View {
    @Environment(HealthKit.self) private var vm
    
    @State private var sheetNewRecord = false
    
    var body: some View {
        let dayChunks = vm.glucoseRecords.chunked { lhs, rhs in
            Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
        }
        
        List {
            Section {
                GlucoseChartView(records: vm.glucoseRecords)
                    .listRowInsets(.init())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            
            ForEach(dayChunks.indices, id: \.self) { index in
                let chunk = dayChunks[index]
                
                if let first = chunk.first {
                    Section(Utils.formattedDate(first.date)) {
                        ForEach(chunk) { record in
                            GlucoseCard(record) {
                                vm.deleteGlucose(record)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    vm.deleteGlucose(record)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Blood Glucose")
        .refreshable {
            _ = try? await vm.reloadGlucoseRecords()
        }
        .sheet($sheetNewRecord) {
            NewRecordSheet(.glucose)
                .environment(vm)
                .presentationDetents([.medium])
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
        GlucoseList()
    }
    .darkSchemePreferred()
    .environment(HealthKit())
}
