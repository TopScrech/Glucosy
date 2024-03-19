import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    
    init() {
        requestPermission()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error {
                print("Notification permission denied because: \(error.localizedDescription).")
            }
        }
    }
    
    func scheduleScanReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Measure your glucose"
        content.body = "Don't forget to complete your task!"
        content.categoryIdentifier = "REMINDER"
        content.interruptionLevel = .timeSensitive
        content.sound = .defaultCritical
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 7200,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
//    func fetchScheduledNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
//        UNUserNotificationCenter.current().getPendingNotificationRequests { scheduledNotifications in
//            completion(scheduledNotifications)
//        }
//    }
    
    func removeAllPending() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func removePending(_ identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func fetchScheduledNotifications() async -> [UNNotificationRequest] {
        await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getPendingNotificationRequests { scheduledNotifications in
                print(scheduledNotifications.count)
                continuation.resume(returning: scheduledNotifications)
            }
        }
    }

//    var scheduledNotifications: [UNNotificationRequest] {
//        var notifications: [UNNotificationRequest] = []
//        
//        NotificationManager.shared.fetchScheduledNotifications { scheduledNotifications in
//            for notification in scheduledNotifications {
//                print(notification.identifier)
//                notifications.append(notification)
//            }
//        }
//        
//        return notifications
//    }
}
