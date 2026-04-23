import ScrechKit

struct AddCarbsSheet: View {
    let carbsAmount: Double
    
    var body: some View {
        NewRecordCarbs(initialAmount: carbsAmount)
    }
}
