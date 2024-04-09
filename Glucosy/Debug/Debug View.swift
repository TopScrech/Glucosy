import SwiftUI
import WidgetKit

struct DebugView: View {
    @Environment(AppState.self) private var app
    @Environment(History.self)  private var history
    
    @State private var scheduledNotifications: [UNNotificationRequest] = []
    @State private var skOverlay = false
    
    var body: some View {
        List {
            Section("Widgets") {
                Button("Reload all widgets") {
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
            
            Section("SKOverlay") {
                Button("Present") {
                    skOverlay = true
                }
            }
            
            NavigationLink {
                DataView()
            } label: {
                Label("Data", systemImage: "tray.full.fill")
            }
            
            Section("Scheduled notifications") {
                Button("Cancel all") {
                    NotificationManager.shared.removeAllPending()
                }
                
                Menu {
                    Button("Test passive") {
                        NotificationManager.shared.debugNotification(.passive)
                    }
                    
                    Button("Test active") {
                        NotificationManager.shared.debugNotification(.active)
                    }
                    
                    Button("Test time sensitive") {
                        NotificationManager.shared.debugNotification(.timeSensitive)
                    }
                    
                    Button("Test critical", role: .destructive) {
                        NotificationManager.shared.debugNotification(.critical)
                    }
                } label: {
                    Text("Test")
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
        .appStoreOverlay($skOverlay, id: 1639409934)
        .refreshableTask {
            scheduledNotifications = await NotificationManager.shared.fetchScheduledNotifications()
        }
    }
}

#Preview {
    DebugView()
        .glucosyPreview()
}
