import SwiftUI

enum HomeAction {
    case startNovoPenScan
    
#if os(iOS)
    init?(shortcutItem: UIApplicationShortcutItem) {
        switch shortcutItem.type {
        case Self.startNovoPenScanType:
            self = .startNovoPenScan
            
        default:
            return nil
        }
    }
#endif
    
    private static var startNovoPenScanType: String {
        "\(Bundle.main.bundleIdentifier ?? "dev.topscrech.Glucosy").startNovoPenScan"
    }
}
