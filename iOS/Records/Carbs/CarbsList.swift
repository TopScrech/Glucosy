import ScrechKit

struct CarbsList: View {
    @Environment(HealthKit.self) private var vm
    
    @State private var sheetNewRecord = false
    
    var body: some View {
        List {
            ForEach(vm.carbsRecords) {
                CarbsCard($0)
            }
        }
        .navigationTitle("Carbohydrates")
        .sheet($sheetNewRecord) {
            NewRecordSheet(.carbs)
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
