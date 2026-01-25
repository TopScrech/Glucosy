import SwiftUI

struct TodayQuickActionsView: View {
    let addGlucose: () -> Void
    let addInsulin: () -> Void
    let addCarbs: () -> Void
    let addWeight: () -> Void
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Add")
                .title3(.semibold, design: .rounded)
            
            LazyVGrid(columns: columns, spacing: 12) {
                TodayActionButtonView(
                    title: "Glucose",
                    icon: "drop",
                    color: .red,
                    action: addGlucose
                )
                
                TodayActionButtonView(
                    title: "Insulin",
                    icon: "syringe",
                    color: .yellow,
                    action: addInsulin
                )
                
                TodayActionButtonView(
                    title: "Carbs",
                    icon: "fork.knife",
                    color: .orange,
                    action: addCarbs
                )
                
                TodayActionButtonView(
                    title: "Weight",
                    icon: "scalemass",
                    color: .blue,
                    action: addWeight
                )
            }
        }
    }
}

#Preview {
    TodayQuickActionsView(
        addGlucose: {},
        addInsulin: {},
        addCarbs: {},
        addWeight: {}
    )
    .padding()
    .darkSchemePreferred()
}
