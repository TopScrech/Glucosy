//import UserNotifications
//
//class NotificationManager {
//    static let shared = NotificationManager()
//    
//    init() {
//        
//    }
//    
//    func requestPermission() {
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert]) { granted, error in
//            if granted {
//                print("Notification permission granted")
//            } else if let error {
//                print("Notification permission denied because: \(error.localizedDescription).")
//            }
//        }
//    }
//    
//    func scheduleLocalNotification() {
//        let content = UNMutableNotificationContent()
//        content.title = "Reminder"
//        content.body = "Don't forget to check the app!"
//        content.sound = .default
//        
//        // 5 seconds delay trigger
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//        
//        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//        
//        UNUserNotificationCenter.current().add(request) { error in
//            if let error {
//                print("Error scheduling notification: \(error)")
//            }
//        }
//    }
//    
//    func scheduleCriticalNotification() {
//        let content = UNMutableNotificationContent()
//        content.title = "Reminder"
//        content.body = "Don't forget to complete your task!"
//        content.category = .
//        
//        // Time-sensitive notification
//        if #available(iOS 15.0, *) {
//            content.interruptionLevel = .timeSensitive
//        }
//        
//        // Trigger in 5 seconds
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//        
//        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//        
//        UNUserNotificationCenter.current().add(request) { error in
//            if let error {
//                print("Error scheduling notification: \(error)")
//            }
//        }
//    }
//}
//
//extension UNMutableNotificationContent {
//    enum CategoryIdentifier: String {
//        case actionable = "ACTIONABLE"
//        case message = "MESSAGE"
//        case reminder = "REMINDER"
////        case custom(let identifier) = identifier
//    }
//    
//    var category: CategoryIdentifier
//}
