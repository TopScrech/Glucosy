import ScrechKit
import WidgetKit

struct Monitor: View {
    @Environment(AppState.self) private var app: AppState
    @Environment(Log.self)      private var log: Log
    @Environment(History.self)  private var history: History
    @Environment(Settings.self) private var settings: Settings
    
    @State private var readingCountdown = 0
    @State private var minutesSinceLastReading = 0
    
    var body: some View {
        VStack {
            if let sensor = app.sensor {
                let maxLife = sensor.maxLife / 86400
                
                if maxLife - sensor.age - minutesSinceLastReading > 0 {
                    Text("Ends in \((maxLife - sensor.age - minutesSinceLastReading).formattedInterval)")
                }
            }
            
            HStack {
                VStack {
                    if app.lastReadingDate != Date.distantPast {
                        Text(app.lastReadingDate.shortTime)
                            .monospacedDigit()
                        
                        Text("\(minutesSinceLastReading) min ago")
                            .footnote()
                            .monospacedDigit()
                    } else {
                        Text("---")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 12)
                .foregroundColor(Color(.lightGray))
                .onChange(of: app.lastReadingDate) {
                    minutesSinceLastReading = Int(Date().timeIntervalSince(app.lastReadingDate) / 60)
                }
                
                Text(app.currentGlucose > 0 ? "\(app.currentGlucose.units)" : "---")
                    .font(.system(size: 42, weight: .black))
                    .monospacedDigit()
                    .foregroundColor(.black)
                    .padding(5)
                    .background(app.currentGlucose > 0 && (app.currentGlucose > Int(settings.alarmHigh) || app.currentGlucose < Int(settings.alarmLow)) ? .red : .blue)
                    .clipShape(.rect(cornerRadius: 8))
                
                // TODO: display both delta and trend arrow
                
                Group {
                    if app.trendDeltaMinutes > 0 {
                        VStack {
                            Text("\(app.trendDelta > 0 ? "+ " : app.trendDelta < 0 ? "- " : "")\(app.trendDelta == 0 ? "→" : abs(app.trendDelta).units)")
                                .fontWeight(.black)
                            
                            Text("\(app.trendDeltaMinutes) min")
                                .footnote()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 12)
                        
                    } else {
                        Text(app.trendArrow.symbol)
                            .largeTitle(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 12)
                    }
                }
                .foregroundColor(app.currentGlucose > 0 && ((app.currentGlucose > Int(settings.alarmHigh) && (app.trendDelta > 0 || app.trendArrow == .rising || app.trendArrow == .risingQuickly)) || (app.currentGlucose < Int(settings.alarmLow) && (app.trendDelta < 0 || app.trendArrow == .falling || app.trendArrow == .fallingQuickly))) ?
                    .red : .blue)
            }
            
            Text("\(app.glycemicAlarm.description.replacingOccurrences(of: "_", with: " "))\(app.glycemicAlarm.description != "" ? " - " : "")\(app.trendArrow.description.replacingOccurrences(of: "_", with: " "))")
                .foregroundColor(app.currentGlucose > 0 && ((app.currentGlucose > Int(settings.alarmHigh) && (app.trendDelta > 0 || app.trendArrow == .rising || app.trendArrow == .risingQuickly)) || (app.currentGlucose < Int(settings.alarmLow) && (app.trendDelta < 0 || app.trendArrow == .falling || app.trendArrow == .fallingQuickly))) ?
                    .red : .blue)
            
            HStack {
                Text(app.deviceState)
                    .foregroundColor(app.deviceState == "Connected" ? .green : .red)
                    .fixedSize()
                
                if !app.deviceState.isEmpty && app.deviceState != "Disconnected" {
                    Text(readingCountdown > 0 || app.deviceState == "Reconnecting..." ?
                         "\(readingCountdown) s" : "")
                    .fixedSize()
                    .callout()
                    .monospacedDigit()
                    .foregroundColor(.orange)
                    .onReceive(app.secondTimer) { _ in
                        readingCountdown = settings.readingInterval * 60 - Int(Date().timeIntervalSince(app.lastConnectionDate))
                    }
                }
            }
            
            Graph()
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                if app.sensor != nil && (app.sensor.state != .unknown || app.sensor.serial != "") {
                    VStack {
                        Text(app.sensor.state.description)
                            .foregroundColor(app.sensor.state == .active ? .green : .red)
                        
                        if app.sensor.age > 0 {
                            Text(app.sensor.age.shortFormattedInterval)
                        }
                    }
                }
                
                // let battery = app.device.battery
                // let battery = app.device.battery
                
                if app.device != nil && (app.device.battery > -1 || app.device.rssi != 0) {
                    VStack {
                        if app.device.battery > -1 {
                            let battery = app.device.battery
                            
                            HStack(spacing: 4) {
                                let ext = battery > 95 ? 100 :
                                battery > 65 ? 75 :
                                battery > 35 ? 50 :
                                battery > 10 ? 25 : 0
                                
                                Image(systemName: "battery.\(ext)")
                                
                                Text("\(battery)%")
                            }
                            .foregroundColor(battery > 10 ? .green : .red)
                        }
                    }
                }
            }
            .footnote()
            .foregroundColor(.yellow)
            
            Text(app.status)
                .footnote()
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity)
            
            Spacer()
            
            Spacer()
            
            HStack {
                Button {
                    app.main.rescan()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                
                if (app.status.hasPrefix("Scanning") || app.status.hasSuffix("retrying...")) && app.main.centralManager.state != .poweredOff {
                    Button {
                        app.main.centralManager.stopScan()
                        
                        app.main.status("Stopped scanning")
                        app.main.log("Bluetooth: stopped scanning")
                        
                    } label: {
                        Image(systemName: "stop.circle")
                    }
                    .foregroundColor(.red)
                }
            }
            .title()
            .padding(.bottom, 8)
        }
        .navigationTitle("Monitor")
        .multilineTextAlignment(.center)
        .navigationBarTitleDisplayMode(.inline)
        .standardToolbar()
        .onReceive(app.minuteTimer) { _ in
            minutesSinceLastReading = Int(Date().timeIntervalSince(app.lastReadingDate) / 60)
        }
        .onAppear {
            if app.lastReadingDate != Date.distantPast {
                minutesSinceLastReading = Int(Date().timeIntervalSince(app.lastReadingDate) / 60)
            }
        }
    }
}

#Preview {
    NavigationView {
        HomeView()
    }
    .glucosyPreview(.monitor)
}
