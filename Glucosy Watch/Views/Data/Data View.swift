import SwiftUI

struct DataView: View {
    @Environment(AppState.self) private var app: AppState
    @Environment(History.self)  private var history: History
    @Environment(Settings.self) private var settings: Settings
    
    @State private var onlineCountdown = 0
    @State private var readingCountdown = 0
    
    var body: some View {
        VStack {
            let dateTime = (app.lastReadingDate != Date.distantPast ? app.lastReadingDate : Date()).dateTime
            
            Text(dateTime)
            
            HStack {
                if app.status.hasPrefix("Scanning") && !(readingCountdown > 0) {
                    Text("Scanning...")
                        .foregroundColor(.orange)
                    
                } else {
                    HStack {
                        if !app.deviceState.isEmpty && app.deviceState != "Connected" {
                            Text(app.deviceState)
                                .foregroundColor(.red)
                        }
                        
                        Text(readingCountdown > 0 || app.deviceState == "Reconnecting..." ?
                             "\(readingCountdown) s" : " ")
                        .foregroundColor(.orange)
                        // .caption()
                        // .monospacedDigit()
                        .onReceive(app.secondTimer) { _ in
                            // workaround: watchOS fails converting the interval to an Int32
                            
                            if app.lastConnectionDate == Date.distantPast {
                                readingCountdown = 0
                            } else {
                                readingCountdown = settings.readingInterval * 60 - Int(Date().timeIntervalSince(app.lastConnectionDate))
                            }
                        }
                    }
                    
                    Text(onlineCountdown > 0 ? "\(onlineCountdown) s" : "")
                        .foregroundColor(.cyan)
                        .onReceive(app.secondTimer) { _ in
                            // workaround: watchOS fails converting the interval to an Int32
                            
                            if settings.lastOnlineDate == Date.distantPast {
                                onlineCountdown = 0
                            } else {
                                onlineCountdown = settings.onlineInterval * 60 - Int(Date().timeIntervalSince(settings.lastOnlineDate))
                            }
                        }
                }
            }
            
            List {
                NavigationLink("History") {
                    DataList("History", data: history.factoryValues)
                        .foregroundColor(.orange)
                }
                .foregroundColor(.orange)
                
                NavigationLink("Trend") {
                    DataList("Trend", data: history.factoryTrend)
                        .foregroundColor(.orange)
                }
                .foregroundColor(.orange)
                
                NavigationLink("Raw Trend") {
                    DataList("Raw trend", data: history.rawTrend)
                        .foregroundColor(.yellow)
                }
                .foregroundColor(.yellow)
                
                NavigationLink("Raw Values") {
                    DataList("Raw values", data: history.rawValues)
                        .foregroundColor(.yellow)
                }
                .foregroundColor(.yellow)
                
                NavigationLink("OOP History") {
                    DataList("OOP History", data: history.values)
                        .foregroundColor(.blue)
                }
                .foregroundColor(.blue)
                
                NavigationLink("HealthKit") {
                    DataServiceList("HealthKit", data: history.glucose)
                        .foregroundColor(.red)
                }
                .foregroundColor(.red)
                
                NavigationLink("Nightscout") {
                    DataServiceList("Nightscout", data: history.nightscoutValues)
                        .foregroundColor(.cyan)
                }
                .foregroundColor(.cyan)
                
                // TODO: LLU
            }
        }
        .navigationTitle("Data")
        .footnote()
        // .monospaced()
    }
}

#Preview {
    NavigationView {
        DataView()
    }
    .glucosyPreview(.data)
}
