import SwiftUI

struct CaloriesContentView: View {
    @Environment(HealthKit.self) private var healthKit

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Today")
                    .headline()

                CaloriesEnergyCardView(kind: .active)

                CaloriesEnergyCardView(kind: .dietary)
            }
            .padding()
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Calories")
        .navigationDestination(for: EnergyKind.self) {
            EnergyHistoryView(kind: $0)
        }
        .refreshable {
            await healthKit.refreshCalories()
        }
    }
}
