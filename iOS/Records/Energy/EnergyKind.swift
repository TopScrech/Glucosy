import SwiftUI
import HealthyKit

enum EnergyKind: CaseIterable {
    case resting, active, dietary

    var quantityType: HKQuantityType {
        switch self {
        case .resting: .basalEnergyBurned
        case .active: .activeEnergyBurned
        case .dietary: .dietaryEnergyConsumed
        }
    }

    var title: String {
        switch self {
        case .resting: String(localized: "Resting Energy")
        case .active: String(localized: "Active Energy")
        case .dietary: String(localized: "Dietary Energy")
        }
    }

    var icon: String {
        switch self {
        case .resting: "bed.double"
        case .active: "flame"
        case .dietary: "fork.knife"
        }
    }

    var color: Color {
        switch self {
        case .resting: .purple
        case .active: .pink
        case .dietary: .orange
        }
    }

    var destination: TodayMetricDestination {
        switch self {
        case .resting: .restingEnergy
        case .active: .activeEnergy
        case .dietary: .dietaryEnergy
        }
    }
}
