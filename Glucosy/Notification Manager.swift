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
    
    func scheduleScanReminder(_ interruptionLevel: UNNotificationInterruptionLevel = .timeSensitive) {
        let content = UNMutableNotificationContent()
        content.title = "Measure your glucose"
        content.body = "Don't forget to complete your task!"
        content.categoryIdentifier = "REMINDER"
        content.interruptionLevel = interruptionLevel
        content.sound = .defaultCritical
        
        let startNewScanAction = UNNotificationAction(
            identifier: "START_NEW_SCAN",
            title: "Start new Scan",
            options: [.foreground, .authenticationRequired]
        )
        
        let reminderCategory = UNNotificationCategory(
            identifier: "REMINDER",
            actions: [startNewScanAction],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "",
            options: .customDismissAction
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([reminderCategory])
        
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
    
    func removeAllPending() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func removePending(_ identifiers: String...) {
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
}
