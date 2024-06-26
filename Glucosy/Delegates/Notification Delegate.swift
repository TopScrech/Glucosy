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
        let categoryIdentifier = response.notification.request.content.categoryIdentifier
        
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            
            // MARK: Default Actions (on tap)
            
            switch categoryIdentifier {
            case "ALARM":
                app.sheetNewRecord = true
                
            case "REMINDER":
                app.main.nfc.startSession()
                
            case "ACTIVATED":
                app.main.nfc.startSession()
                
            default:
                break
            }
        } else {
            
            // MARK: Custom Actions (on hold)
            
            switch response.actionIdentifier {
            case "NEW_SCAN":
                app.main.nfc.startSession()
                
            case "ACTIVATED":
                app.main.nfc.startSession()
                
            case "NEW_RECORD":
                app.sheetNewRecord = true
                
            case "ACTIVATE_SENSOR":
                if app.main.nfc.isAvailable {
                    settings.logging = true
                    app.dialogActivate = true
                } else {
                    app.alertNfc = true
                }
                
            default:
                print("Unknown identifier \(response.actionIdentifier)")
                print(categoryIdentifier)
            }
        }
        
        completionHandler()
    }
}
