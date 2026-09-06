import SwiftUI

struct CaloriesEnergyCardView: View {
    @Environment(HealthKit.self) private var healthKit
    let kind: EnergyKind

    var body: some View {
        NavigationLink(value: kind) {
            TodayMetricCard(metric: healthKit.energyMetricCard(for: kind))
        }
        .buttonStyle(.plain)
    }
}
