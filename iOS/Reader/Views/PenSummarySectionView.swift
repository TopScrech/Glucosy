import SwiftUI

struct PenSummarySectionView: View {
    let reading: PenReading

    var body: some View {
        Section("Pen") {
            LabeledContent("Model") {
                Text(reading.modelDisplayValue)
            }

            LabeledContent("Serial") {
                Text(reading.serialDisplayValue)
            }

            LabeledContent("Dose count") {
                Text(reading.doses.count, format: .number)
            }

            LabeledContent("Captured") {
                Text(reading.capturedAt, format: .dateTime.year().month().day().hour().minute())
            }

            LabeledContent("Pen started") {
                if let penStartedAt = reading.penStartedAtDisplayValue {
                    Text(penStartedAt, format: .dateTime.year().month().day().hour().minute())
                } else {
                    Text("Unavailable")
                }
            }
        }
    }
}
