import UserNotifications

extension NotificationManager {
    func scheduleAlarmReminder(
        _ title: String,
        subtitle: String = "",
        after interval: TimeInterval = 0.01
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.categoryIdentifier = "ALARM"
        content.sound = .defaultCritical
        content.interruptionLevel = .timeSensitive
        
        let actions = [
            NotificationAction.newRecord()
        ]
        
        let reminderCategory = UNNotificationCategory(
            identifier: "ALARM",
            actions: actions,
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "",
            options: .customDismissAction
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([reminderCategory])
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: interval,
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
