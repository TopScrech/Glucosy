import SwiftUI

struct SettingsNotification: View {
    @Environment(AppState.self) private var app: AppState
    @Environment(Settings.self) private var settings: Settings
    
    var body: some View {
        @Bindable var settings = settings
        
        HStack {
            Button {
                withAnimation {
                    settings.disabledNotifications.toggle()
                }
                
                if settings.disabledNotifications {
                    UNUserNotificationCenter.current().setBadgeCount(0)
                } else {
                    UNUserNotificationCenter.current().setBadgeCount(
                        settings.displayingMillimoles ? Int(Float(app.currentGlucose.units)! * 10) : Int(app.currentGlucose.units)!
                    )
                }
            } label: {
                Image(systemName: settings.disabledNotifications ? "zzz" : "app.badge.fill")
            }
            
            if settings.disabledNotifications {
                Picker("", selection: $settings.alarmSnoozeInterval) {
                    ForEach([5, 15, 30, 60, 120], id: \.self) { t in
                        Text("\([5: "5 min", 15: "15 min", 30: "30 min", 60: "1 h", 120: "2 h"][t]!)")
                    }
                }
                .labelsHidden()
            }
        }
    }
}

#Preview {
    SettingsNotification()
}
