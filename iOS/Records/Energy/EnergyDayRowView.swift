import ScrechKit

struct EnergyDayRowView: View {
    let day: EnergyDay
    let kind: EnergyKind

    var body: some View {
        HStack {
            Label {
                Text(Utils.formattedDate(day.date))
                    .foregroundStyle(.primary)
            } icon: {
                Image(systemName: kind.icon)
                    .foregroundStyle(kind.color)
            }
            Spacer()
            Text(day.value, format: .number.precision(.fractionLength(0)))
                .monospacedDigit()
            Text("kcal")
                .secondary()
        }
    }
}
