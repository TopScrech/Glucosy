import ScrechKit

struct InsulinList: View {
    @Environment(HealthKit.self) private var vm
    
    @State private var sheetNewRecord = false
    
    var body: some View {
        List {
            ForEach(vm.insulinRecords) { record in
                InsulinCard(record)
            }
        }
        .sheet($sheetNewRecord) {
            Text("New record")
        }
        .toolbar {
            SFButton("note.text.badge.plus") {
                sheetNewRecord = true
            }
        }
    }
}

#Preview {
    InsulinList()
}
