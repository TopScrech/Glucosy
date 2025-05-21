import ScrechKit

struct GlucoseList: View {
    @Environment(HealthKit.self) private var vm
    
    @State private var sheetNewRecord = false
    
    var body: some View {
        List {
            ForEach(vm.glucoseRecords) { record in
                GlucoseCard(record)
            }
        }
        .navigationTitle("Blood Glucose")
        .sheet($sheetNewRecord) {
            NewRecordSheet(.glucose)
        }
        .toolbar {
            SFButton("note.text.badge.plus") {
                sheetNewRecord = true
            }
        }
    }
}

#Preview {
    GlucoseList()
        .environment(HealthKit())
}
