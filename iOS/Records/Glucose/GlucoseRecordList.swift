import ScrechKit
import Algorithms

struct GlucoseRecordList: View {
    @Environment(HealthKit.self) private var vm
    
    @State private var sheetNewRecord = false
    
    var body: some View {
        let dayChunks = vm.glucoseRecords.chunked { lhs, rhs in
            Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
        }
        
        List {
            Section {
                GlucoseChart(vm.glucoseRecords)
                    .listRowInsets(.init())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            
            ForEach(dayChunks.indices, id: \.self) { index in
                let chunk = dayChunks[index]
                
                if let first = chunk.first {
                    Section(Utils.formattedDate(first.date)) {
                        ForEach(chunk) {
                            GlucoseRecordCard($0)
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
            SFButton("plus") {
                sheetNewRecord = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        GlucoseRecordList()
    }
    .darkSchemePreferred()
    .environment(HealthKit())
}
