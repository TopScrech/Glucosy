import Observation
import UIKit

@Observable
@MainActor
final class AppRouter {
    private(set) var quickActionRequest = 0
    private var pendingQuickAction: HomeQuickAction?

    static let shared = AppRouter()

    func handle(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        guard let quickAction = HomeQuickAction(shortcutItem: shortcutItem) else {
            return false
        }

        pendingQuickAction = quickAction
        quickActionRequest += 1
        return true
    }

    func consumePendingQuickAction() -> HomeQuickAction? {
        let quickAction = pendingQuickAction
        pendingQuickAction = nil
        return quickAction
    }
}
