import SwiftUI

struct DoseRow: View {
    let dose: DoseEntry
    let match: DoseHealthKitMatch
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(dose.timestamp, format: .dateTime.year().month().day())
                
                Text(dose.timestamp, format: .dateTime.hour().minute())
                    .secondary()
                
                if match == .missing {
                    Text("Missing in HealthKit")
                        .foregroundStyle(.orange)
                }
            }
            
            Spacer()
            
            Text("\(dose.units, format: .number.precision(.fractionLength(1))) U")
                .bold()
        }
    }
}
