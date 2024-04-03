import UserNotifications

final class NotificationAction {
    static func newScan() -> UNNotificationAction {
        .init(
            identifier: "NEW_SCAN",
            title: "New Scan",
            options: [.foreground, .authenticationRequired]
        )
    }
    
    static func newRecord() -> UNNotificationAction {
        .init(
            identifier: "NEW_RECORD",
            title: "New record",
            options: [.foreground, .authenticationRequired]
        )
    }
    
    static func activateSensor() -> UNNotificationAction {
        .init(
            identifier: "ACTIVATE_SENSOR",
            title: "Activate new sensor",
            options: [.foreground, .authenticationRequired],
            icon: .init(systemImageName: "sensor.tag.radiowaves.forward.fill")
        )
    }
}
