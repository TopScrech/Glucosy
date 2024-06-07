import ScrechKit
import UserNotifications

extension NotificationManager {
    func scheduleScanReminder(_ interruptionLevel: UNNotificationInterruptionLevel = .timeSensitive) {
        let content = UNMutableNotificationContent()
        content.title = "Measure your glucose"
        content.body = "Don't forget to complete your task!"
        content.categoryIdentifier = "REMINDER"
        content.interruptionLevel = interruptionLevel
        content.sound = .criticalSoundNamed(.init("Alarm high.mp3"), withAudioVolume: 0.5)
//        content.sound = .critical("Alarm high.mp3", volume: 0.5)
        #warning("Wtf ")
        
        let actions = [
            NotificationAction.newScan()
        ]
        
        let reminderCategory = UNNotificationCategory(
            identifier: "REMINDER",
            actions: actions,
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
}
