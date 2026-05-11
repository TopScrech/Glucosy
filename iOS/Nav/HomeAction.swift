import SwiftUI

enum HomeAction {
    case openAssistant, startNovoPenScan
    
#if os(iOS)
    init?(shortcutItem: UIApplicationShortcutItem) {
        switch shortcutItem.type {
        case Self.openAssistantType:
            self = .openAssistant
            
        case Self.startNovoPenScanType:
            self = .startNovoPenScan
            
        default:
            return nil
        }
    }
#endif
    
    private static var openAssistantType: String {
        "\(Bundle.main.bundleIdentifier ?? "dev.topscrech.Glucosy").openAssistant"
    }
    
    private static var startNovoPenScanType: String {
        "\(Bundle.main.bundleIdentifier ?? "dev.topscrech.Glucosy").startNovoPenScan"
    }
}
