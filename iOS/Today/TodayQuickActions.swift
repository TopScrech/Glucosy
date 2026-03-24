import SwiftUI

struct TodayQuickActions: View {
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
                TodayActionButton(
                    title: "Glucose",
                    icon: "drop",
                    color: .red,
                    action: addGlucose
                )
                
                TodayActionButton(
                    title: "Insulin",
                    icon: "syringe",
                    color: .yellow,
                    action: addInsulin
                )
                
                TodayActionButton(
                    title: "Carbs",
                    icon: "fork.knife",
                    color: .orange,
                    action: addCarbs
                )
                
                TodayActionButton(
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
    TodayQuickActions(
        addGlucose: {},
        addInsulin: {},
        addCarbs: {},
        addWeight: {}
    )
    .padding()
    .darkSchemePreferred()
}
