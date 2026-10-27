import ScrechKit

struct InsulinSectionHeaderView: View {
    let day: HealthRecordDay<Insulin>

    var body: some View {
        HStack {
            Text(Utils.formattedDate(day.date))

            Spacer()

            ForEach(InsulinType.allCases) { type in
                HStack(spacing: 2) {
                    Text(day.total(for: type), format: .number)
                        .monospacedDigit()

                    Image(systemName: type == .bolus ? "syringe" : "syringe.fill")
                        .foregroundStyle(type == .bolus ? .yellow : .purple)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(type.title): \(day.total(for: type).formatted()) U")
            }
        }
    }
}
