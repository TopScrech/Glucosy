import SwiftUI

struct DoseRowView: View {
    let dose: DoseEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(dose.timestamp, format: .dateTime.year().month().day())
                Text(dose.timestamp, format: .dateTime.hour().minute())
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(dose.units, format: .number.precision(.fractionLength(1))) U")
                .bold()
        }
    }
}
