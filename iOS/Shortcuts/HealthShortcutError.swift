import Foundation

enum HealthShortcutError: LocalizedError {
    case carbsAuthorizationDenied
    case invalidCarbs
    case invalidInsulin
    case invalidWeight
    case insulinAuthorizationDenied
    case weightAuthorizationDenied
    case healthKitUnavailable

    var errorDescription: String? {
        switch self {
        case .carbsAuthorizationDenied:
            String(localized: "Glucosy does not have permission to write carbohydrates to Health")
        case .invalidCarbs:
            String(localized: "Enter a carbohydrate amount greater than zero")
        case .invalidInsulin:
            String(localized: "Enter an insulin amount greater than zero")
        case .invalidWeight:
            String(localized: "Enter a weight greater than zero")
        case .insulinAuthorizationDenied:
            String(localized: "Glucosy does not have permission to write insulin to Health")
        case .weightAuthorizationDenied:
            String(localized: "Glucosy does not have permission to write weight to Health")
        case .healthKitUnavailable:
            String(localized: "HealthKit is not available on this device")
        }
    }
}
