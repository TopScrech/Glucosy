import ScrechKit

struct InsulinSectionHeaderView: View {
    let day: HealthRecordDay<Insulin>

    var body: some View {
        HStack {
            Text(Utils.formattedDate(day.date))

            Spacer()

            ForEach(InsulinType.allCases) { type in
                let total = day.total(for: type)

                if total > 0 {
                    HStack(spacing: 2) {
                        Text(total, format: .number)
                            .monospacedDigit()

                        Image(systemName: type == .bolus ? "syringe" : "syringe.fill")
                            .foregroundStyle(type == .bolus ? .yellow : .purple)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(type.title): \(total.formatted()) U")
                }
            }
        }
    }
}
