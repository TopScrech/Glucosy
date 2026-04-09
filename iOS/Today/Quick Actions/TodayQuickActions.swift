import ScrechKit

struct TodayQuickActions: View {
    @Environment(HealthKit.self) private var vm
    
    @State private var sheetNewInsulinRecord = false
    @State private var sheetNewCarbsRecord = false
    @State private var sheetNewGlucoseRecord = false
    @State private var sheetNewWeightRecord = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Add")
                .title3(.semibold, design: .rounded)
            
            LazyVGrid(columns: columns, spacing: 12) {
                TodayActionButton("Glucose", icon: "drop", color: .red) {
                    sheetNewGlucoseRecord = true
                }
                
                TodayActionButton("Insulin", icon: "syringe", color: .yellow) {
                    sheetNewInsulinRecord = true
                }
                
                TodayActionButton("Carbs", icon: "fork.knife", color: .orange) {
                    sheetNewCarbsRecord = true
                }
                
                TodayActionButton("Weight", icon: "scalemass", color: .blue) {
                    sheetNewWeightRecord = true
                }
            }
        }
        .sheet($sheetNewGlucoseRecord) {
            NewRecordSheet(.glucose)
        }
        .sheet($sheetNewInsulinRecord) {
            NewRecordSheet(.insulin)
        }
        .sheet($sheetNewCarbsRecord) {
            NewRecordSheet(.carbs)
        }
        .sheet($sheetNewWeightRecord) {
            NavigationStack {
                LogWeightSheet()
            }
        }
        .environment(vm)
    }
}

#Preview {
    TodayQuickActions()
        .padding()
        .darkSchemePreferred()
}
