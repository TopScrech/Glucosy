import Foundation

enum InsulinShortcutError: LocalizedError {
    case invalidUnits
    case authorizationDenied

    var errorDescription: String? {
        switch self {
        case .invalidUnits:
            String(localized: "Enter an insulin amount greater than zero")
        case .authorizationDenied:
            String(localized: "Glucosy does not have permission to write insulin to Health")
        }
    }
}
