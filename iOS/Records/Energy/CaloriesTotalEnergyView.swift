import ScrechKit

struct CaloriesTotalEnergyView: View {
    @Environment(HealthKit.self) private var healthKit

    var body: some View {
        VStack(alignment: .leading) {
            Text("Total Energy")
                .headline()

            HStack(alignment: .firstTextBaseline) {
                Group {
                    if let total = healthKit.totalEnergyToday {
                        Text(total, format: .number.precision(.fractionLength(0)))
                    } else {
                        Text("-")
                    }
                }
                .title2(.semibold, design: .rounded)
                .monospacedDigit()

                Text("kcal")
                    .caption()
                    .secondary()
            }
        }
        .padding(.vertical)
    }
}
