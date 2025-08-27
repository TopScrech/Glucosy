import ScrechKit

struct WeightList: View {
    @State private var sheetNewEntry = false
    
    var body: some View {
        List {
            
        }
        .navigationTitle("Weight")
        .sheet($sheetNewEntry) {
            NavigationStack {
                LogWeightSheet()
            }
        }
        .toolbar {
            SFButton("plus") {
                sheetNewEntry = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        WeightList()
    }
}
