import ScrechKit

struct CarbsList: View {
    @Environment(HealthKit.self) private var vm
    
    @State private var sheetNewRecord = false
    
    var body: some View {
        List {
            ForEach(vm.carbsRecords) { record in
                CarbsCard(record)
            }
        }
        .sheet($sheetNewRecord) {
            NewRecordSheet()
        }
        .toolbar {
            SFButton("note.text.badge.plus") {
                sheetNewRecord = true
            }
        }
    }
}

#Preview {
    CarbsList()
}
