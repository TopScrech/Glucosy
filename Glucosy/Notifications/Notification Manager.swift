import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    
    init() {
        requestPermission()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .criticalAlert]) { granted, error in
            if let error {
                print("Notification permission denied: \(error.localizedDescription).")
            }
        }
    }
    
    func scheduleNotification(_ request: UNNotificationRequest) {
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func removeAllPending() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func removePending(_ identifiers: String...) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func fetchScheduledNotifications() async -> [UNNotificationRequest] {
        await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
                print(notifications.count)
                
                continuation.resume(returning: notifications)
            }
        }
    }
}
