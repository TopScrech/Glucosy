import Foundation

enum HealthShortcutError: LocalizedError {
    case invalidCarbs
    case invalidInsulin
    case invalidWeight
    case authorizationDenied
    case healthKitUnavailable

    var errorDescription: String? {
        switch self {
        case .invalidCarbs:
            String(localized: "Enter a carbohydrate amount greater than zero")
        case .invalidInsulin:
            String(localized: "Enter an insulin amount greater than zero")
        case .invalidWeight:
            String(localized: "Enter a weight greater than zero")
        case .authorizationDenied:
            String(localized: "Glucosy does not have permission to write this data to Health")
        case .healthKitUnavailable:
            String(localized: "HealthKit is not available on this device")
        }
    }
}
