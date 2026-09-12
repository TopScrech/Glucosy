import SwiftUI
import HealthyKit

enum EnergyKind: CaseIterable {
    case active, dietary

    var quantityType: HKQuantityType {
        switch self {
        case .active: .activeEnergyBurned
        case .dietary: .dietaryEnergyConsumed
        }
    }

    var title: String {
        switch self {
        case .active: String(localized: "Active Energy")
        case .dietary: String(localized: "Dietary Energy")
        }
    }

    var icon: String {
        switch self {
        case .active: "flame"
        case .dietary: "fork.knife"
        }
    }

    var color: Color {
        switch self {
        case .active: .pink
        case .dietary: .orange
        }
    }

    var destination: TodayMetricDestination {
        switch self {
        case .active: .activeEnergy
        case .dietary: .dietaryEnergy
        }
    }
}
