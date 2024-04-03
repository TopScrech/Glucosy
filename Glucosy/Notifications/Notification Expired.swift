import UserNotifications

extension NotificationManager {
    func scheduleExpired(_ sensor: SensorType) {
        let content = UNMutableNotificationContent()
        content.title = "\(sensor) has expired"
        content.categoryIdentifier = "EXPIRED"
        content.sound = .defaultCritical
        content.interruptionLevel = .timeSensitive
        
        let reminderCategory = UNNotificationCategory(
            identifier: "EXPIRED",
            actions: [saveAnywaysAction],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "",
            options: .customDismissAction
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([reminderCategory])
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 0.01,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "Glucosy",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}
