import SwiftUI
import UserNotifications

extension NotificationManager {
    func debugNotification(_ interruptionLevel: UNNotificationInterruptionLevel) {
        let content = UNMutableNotificationContent()
        content.title =              "Title"
        content.subtitle =           "Subtitle"
        content.body =               "Body"
        content.categoryIdentifier = "DEBUG"
        content.interruptionLevel =  interruptionLevel
        content.sound = .criticalSoundNamed(.init("Alarm high.mp3"), withAudioVolume: 0.5)
        //        content.sound = .critical("Alarm high.mp3", volume: 0.5)
        #warning("Wtf")
        
        let actions = [
            NotificationAction.newScan()
        ]
        
        let reminderCategory = UNNotificationCategory(
            identifier: "DEBUG",
            actions: actions,
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "",
            options: .customDismissAction
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([reminderCategory])
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "Glucosy",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
}
