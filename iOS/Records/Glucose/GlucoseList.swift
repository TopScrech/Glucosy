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
            ForEach(dayChunks.indices, id: \.self) { index in
                let chunk = dayChunks[index]
                
                if let first = chunk.first {
                    Section(Utils.formattedDate(first.date)) {
                        ForEach(chunk) { record in
                            GlucoseCard(record)
                        }
                    }
                }
            }
        }
        .navigationTitle("Blood Glucose")
        .sheet($sheetNewRecord) {
            NewRecordSheet(.glucose)
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
