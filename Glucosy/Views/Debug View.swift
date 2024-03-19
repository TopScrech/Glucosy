import SwiftUI

struct DebugView: View {
    @State private var scheduledNotifications: [UNNotificationRequest] = []
    
    var body: some View {
        List {
            Section("Scheduled notifications") {
                Button("Cancel all") {
                    NotificationManager.shared.removeAllPending()
                }
                
                ForEach(scheduledNotifications, id: \.identifier) { notification in
                    VStack {
                        Text(notification.content.title)
                        
                        Text(notification.content.subtitle)
                        
                        if let trigger = notification.trigger as? UNTimeIntervalNotificationTrigger {
                            Text("Interval: \(trigger.timeInterval)")
                        }
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            NotificationManager.shared.removePending(notification.identifier)
                        } label: {
                            Label("Cancel", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Debug")
        .refreshableTask {
            scheduledNotifications = await NotificationManager.shared.fetchScheduledNotifications()
        }
    }
}

#Preview {
    DebugView()
}
