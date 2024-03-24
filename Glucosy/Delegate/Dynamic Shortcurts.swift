import SwiftUI

extension MainDelegate {
    func addQuickActions() {
        UIApplication.shared.shortcutItems = [
            .init(
                type: "NFC",
                localizedTitle: "New Scan",
                localizedSubtitle: "Start a new NFC scan",
                icon: .init(systemImageName: "sensor.tag.radiowaves.forward.fill"),
                userInfo: nil
            )
        ]
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem {
            shortcutItemToProcess = shortcutItem
        }
        
        let sceneConfiguration = UISceneConfiguration(name: "Custom Configuration", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = MainDelegate.self
        
        return sceneConfiguration
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        shortcutItemToProcess = shortcutItem
        switch shortcutItem.type {
        case "NFC":
            nfc.startSession()
            
        default:
            print("Unknown dynamic shortcut: \(shortcutItem.type)")
        }
    }
}
