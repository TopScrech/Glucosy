import SwiftUI

struct CaloriesView: View {
    @Environment(HealthKit.self) private var healthKit

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Today")
                        .headline()

                    HStack {
                        CaloriesEnergyCardView(kind: .active)
                        CaloriesEnergyCardView(kind: .resting)
                    }

                    Divider()

                    CaloriesTotalEnergyView()

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
}
