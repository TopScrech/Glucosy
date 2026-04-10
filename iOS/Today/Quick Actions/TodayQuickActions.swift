import ScrechKit

struct TodayQuickActions: View {
    @Environment(HealthKit.self) private var vm
    
    @State private var insulinType: InsulinType?
    @State private var sheetNewCarbsRecord = false
    @State private var sheetNewGlucoseRecord = false
    @State private var sheetNewWeightRecord = false
    @State private var sheetNewBMIRecord = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Add")
                .title3(.semibold, design: .rounded)
            
            LazyVGrid(columns: columns, spacing: 12) {
                TodayActionButton("Bolus", icon: "syringe", color: .yellow) {
                    insulinType = .bolus
                }
                
                TodayActionButton("Basal", icon: "syringe.fill", color: .purple) {
                    insulinType = .basal
                }
                
                TodayActionButton("Glucose", icon: "drop", color: .red) {
                    sheetNewGlucoseRecord = true
                }
                
                TodayActionButton("Carbs", icon: "fork.knife", color: .orange) {
                    sheetNewCarbsRecord = true
                }
                
                TodayActionButton("Weight", icon: "scalemass", color: .blue) {
                    sheetNewWeightRecord = true
                }
                
                TodayActionButton("BMI", icon: "figure", color: .mint) {
                    sheetNewBMIRecord = true
                }
            }
        }
        .sheet($sheetNewGlucoseRecord) {
            NewRecordSheet(.glucose)
        }
        .sheet(item: $insulinType) {
            NewRecordSheet(.insulin, insulinType: $0)
        }
        .sheet($sheetNewCarbsRecord) {
            NewRecordSheet(.carbs)
        }
        .sheet($sheetNewWeightRecord) {
            NewRecordSheet(.weight)
        }
        .sheet($sheetNewBMIRecord) {
            NewRecordSheet(.bmi)
        }
        .environment(vm)
    }
}

#Preview {
    TodayQuickActions()
        .padding()
        .darkSchemePreferred()
}
