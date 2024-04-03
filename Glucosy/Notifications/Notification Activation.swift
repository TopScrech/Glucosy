import UserNotifications

extension NotificationManager {
    func scheduleActivation(_ sensor: SensorType) {
        let content = UNMutableNotificationContent()
        content.title = "\(sensor) is activated"
        content.body = "You can take the first measurement right now!"
        content.categoryIdentifier = "ACTIVATED"
        content.sound = .defaultCritical
        content.interruptionLevel = .timeSensitive
        
        let actions = [
            NotificationAction.newScan()
        ]
        
        let reminderCategory = UNNotificationCategory(
            identifier: "ACTIVATED",
            actions: actions,
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "",
            options: .customDismissAction
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([reminderCategory])
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 3600,
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
