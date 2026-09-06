import ScrechKit

struct EnergyDayRowView: View {
    let day: EnergyDay
    let kind: EnergyKind

    var body: some View {
        HStack {
            Label(Utils.formattedDate(day.date), systemImage: kind.icon)
                .foregroundStyle(kind.color)
            Spacer()
            Text(day.value, format: .number.precision(.fractionLength(0 ... 1)))
                .monospacedDigit()
            Text("kcal")
                .secondary()
        }
    }
}
