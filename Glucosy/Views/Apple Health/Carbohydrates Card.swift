import SwiftUI

struct CarbohydratesCard: View {
    private let carbs: Carbohydrates
    
    init(_ carbs: Carbohydrates) {
        self.carbs = carbs
    }
    
    var body: some View {
        HStack {
            Text(carbs.value)
            
            Spacer()
            
            Text(carbs.date, format: .dateTime)
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
