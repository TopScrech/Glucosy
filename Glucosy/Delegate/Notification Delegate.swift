import SwiftUI

extension MainDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Perform initial setup tasks here
        print("App has finished launching")
        
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    // Notification received in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification actions
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response.actionIdentifier)
        
        switch response.actionIdentifier {
        case "START_NEW_SCAN":
            app.main.nfc.startSession()
            
        case "NEW_RECORD":
            app.sheetMealtime = true
            
        default:
            print("Unknown identifier")
            break
        }
        
        completionHandler()
    }
}
