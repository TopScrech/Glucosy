import SwiftUI

struct CarbohydratesCard: View {
    let carbs: Carbohydrates
    
    init(_ carbs: Carbohydrates) {
        self.carbs = carbs
    }
    
    private var date: String {
        carbs.date.shortDateTime
    }
    
    var body: some View {
        HStack {
            Text(carbs.value)
            
            Spacer()
            
            Text(date)
                .footnote()
                .foregroundStyle(.secondary)
        }
        .monospacedDigit()
    }
}

#Preview {
    List {
        CarbohydratesCard(
            .init(value: 160, date: Date())
        )
    }
    .darkSchemePreferred()
}
