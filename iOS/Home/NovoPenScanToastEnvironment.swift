import SwiftUI

struct NovoPenScanToast {
    let title: String
    let showsViewAll: Bool
    let viewAll: @MainActor () -> Void
}

private struct ShowNovoPenScanToastEnvironmentKey: EnvironmentKey {
    static var defaultValue: @MainActor (NovoPenScanToast) -> Void {
        { _ in }
    }
}

extension EnvironmentValues {
    var showNovoPenScanToast: @MainActor (NovoPenScanToast) -> Void {
        get { self[ShowNovoPenScanToastEnvironmentKey.self] }
        set { self[ShowNovoPenScanToastEnvironmentKey.self] = newValue }
    }
}
