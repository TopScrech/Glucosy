import SwiftUI

enum HomeAction {
    case startNovoPenScan

    init?(shortcutItem: UIApplicationShortcutItem) {
        switch shortcutItem.type {
        case Self.startNovoPenScanType:
            self = .startNovoPenScan
        default:
            return nil
        }
    }

    private static var startNovoPenScanType: String {
        "\(Bundle.main.bundleIdentifier ?? "dev.topscrech.Glucosy").startNovoPenScan"
    }
}
