import SwiftUI

struct InsulinDeliveryCard: View {
    private let insulin: InsulinDelivery
    
    init(_ insulin: InsulinDelivery) {
        self.insulin = insulin
    }
    
    var body: some View {
        HStack {
            if insulin.type == .bolus {
                Image(systemName: "syringe")
            } else {
                Image(systemName: "syringe.fill")
                    .foregroundStyle(.purple)
            }
            
            Text(Int(insulin.amount))
            
            Spacer()
            
            Text(timeFromDate(insulin.date))
                .footnote()
                .foregroundStyle(.secondary)
        }
    }    
}

#Preview {
    List {
        InsulinDeliveryCard(.init(amount: 16, type: .bolus, date: Date()))
        InsulinDeliveryCard(.init(amount: 8, type: .basal, date: Date()))
    }
}
