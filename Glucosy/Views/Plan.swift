import SwiftUI

struct Plan: View {
    @Environment(AppState.self) private var app: AppState
    @Environment(History.self) private var history: History
    @Environment(Log.self) private var log: Log
    @Environment(Settings.self) private var settings: Settings
    
    @State private var onlineCountdown = 0
    @State private var readingCountdown = 0
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            let dateTime = (app.lastReadingDate != Date.distantPast ? app.lastReadingDate : Date()).dateTime
            
            Text(dateTime)
            
            if app.status.hasPrefix("Scanning") {
                Text("Scanning...")
                    .foregroundColor(.orange)
            } else {
                HStack {
                    if !app.deviceState.isEmpty && app.deviceState != "Connected" {
                        Text(app.deviceState).foregroundColor(.red)
                    }
                    
                    Text(readingCountdown > 0 || app.deviceState == "Reconnecting..." ?
                         "\(readingCountdown) s" : " ")
                    .foregroundColor(.orange)
                    .onReceive(timer) { _ in
                        readingCountdown = settings.readingInterval * 60 - Int(Date().timeIntervalSince(app.lastConnectionDate))
                    }
                }
            }
            
            Text(onlineCountdown > 0 ? "\(onlineCountdown) s" : "")
                .foregroundColor(.cyan)
                .onReceive(timer) { _ in
                    onlineCountdown = settings.onlineInterval * 60 - Int(Date().timeIntervalSince(settings.lastOnlineDate))
                }
        }
        .monospacedDigit()
#if targetEnvironment(macCatalyst)
        .padding(.horizontal, 15)
#endif
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Plan")
    }
}

#Preview {
    HomeView()
        .glucosyPreview(.plan)
}
