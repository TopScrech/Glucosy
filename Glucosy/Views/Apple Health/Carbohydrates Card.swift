import SwiftUI

struct CarbohydratesCard: View {
    private let carbs: Carbohydrates
    
    init(_ carbs: Carbohydrates) {
        self.carbs = carbs
    }
    
    var body: some View {
        HStack {
            Text(carbs.amount)
            
            Spacer()
            
            Text(carbs.date, format: .dateTime)
        }
    }
}

#Preview {
    List {
        CarbohydratesCard(
            .init(amount: 160, date: Date())
        )
    }
}
