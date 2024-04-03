import SwiftUI

struct Monitor: View {
    @Environment(AppState.self)         var app: AppState
    @Environment(Log.self)      private var log: Log
    @Environment(History.self)  private var history: History
    @Environment(Settings.self) private var settings: Settings
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var readingCountdown = 0
    @State private var minutesSinceLastReading = 0
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(spacing: 0) {
                    if lastReadingDate != Date.distantPast {
                        Text(lastReadingDate.shortTime)
                            .monospacedDigit()
                        
                        Text("\(minutesSinceLastReading) min ago")
                            .fontSize(10)
                            .monospacedDigit()
                            .lineLimit(1)
                            .onReceive(app.minuteTimer) { _ in
                                minutesSinceLastReading = Int(Date().timeIntervalSince(lastReadingDate) / 60)
                            }
                    } else {
                        Text("---")
                    }
                }
                .footnote()
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundColor(Color(.lightGray))
                .onChange(of: lastReadingDate) {
                    minutesSinceLastReading = Int(Date().timeIntervalSince(lastReadingDate) / 60)
                }
                
                Text(currentGlucose > 0 ? "\(currentGlucose.units)" : "---")
                    .font(.system(size: 26, weight: .black))
                    .monospacedDigit()
                // avoid truncation in 40 mm models
                    .scaledToFill()
                    .minimumScaleFactor(0.85)
                    .foregroundColor(.black)
                    .padding(.vertical, 0)
                    .padding(.horizontal, 4)
                    .background(currentGlucose > 0 && (currentGlucose > Int(settings.alarmHigh) || currentGlucose < Int(settings.alarmLow)) ? .red : .blue)
                    .clipShape(.rect(cornerRadius: 6))
                
                // TODO: display both delta and trend arrow
                
                Group {
                    if app.trendDeltaMinutes > 0 {
                        VStack(spacing: -6) {
                            Text("\(trendDelta > 0 ? "+ " : trendDelta < 0 ? "- " : "")\(trendDelta == 0 ? "→" : abs(trendDelta).units)")
                                .fontWeight(.black)
                                .fixedSize()
                            
                            Text("\(app.trendDeltaMinutes)m")
                                .footnote()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 10)
                        
                    } else {
                        Text(trendArrow.symbol)
                            .fontSize(28)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 10)
                    }
                }
                .foregroundColor(
                    currentGlucose > 0 && ((currentGlucose > Int(settings.alarmHigh) && (trendDelta > 0 || trendArrow == .rising || trendArrow == .risingQuickly)) || (currentGlucose < Int(settings.alarmLow) && (trendDelta < 0 || trendArrow == .falling || trendArrow == .fallingQuickly))) ?
                        .red : .blue
                )
            }
            
            if app.glycemicAlarm.description.count + trendArrow.description.count != 0 {
                Text("\(app.glycemicAlarm.description.replacingOccurrences(of: "_", with: " "))\(app.glycemicAlarm.description != "" ? " - " : "")\(trendArrow.description.replacingOccurrences(of: "_", with: " "))")
                    .footnote()
                    .foregroundColor(
                        currentGlucose > 0 && ((currentGlucose > Int(settings.alarmHigh) && (trendDelta > 0 || trendArrow == .rising || trendArrow == .risingQuickly)) || (currentGlucose < Int(settings.alarmLow) && (trendDelta < 0 || trendArrow == .falling || trendArrow == .fallingQuickly))) ?
                            .red : .blue
                    )
                    .lineLimit(1)
                    .padding(.vertical, -3)
            }
            
            HStack {
                if !deviceState.isEmpty {
                    Text(deviceState)
                        .foregroundColor(deviceState == "Connected" ? .green : .red)
                        .footnote()
                        .fixedSize()
                }
                
                if !deviceState.isEmpty && deviceState != "Disconnected" {
                    Text(readingCountdown > 0 || deviceState == "Reconnecting..." ?
                         "\(readingCountdown) s" : "")
                    .fixedSize()
                    .footnote()
                    .monospacedDigit()
                    .foregroundColor(.orange)
                    .onReceive(app.secondTimer) { _ in
                        // workaround: watchOS fails converting the interval to an Int32
                        
                        if app.lastConnectionDate == Date.distantPast {
                            readingCountdown = 0
                        } else {
                            readingCountdown = settings.readingInterval * 60 - Int(Date().timeIntervalSince(app.lastConnectionDate))
                        }
                    }
                }
            }
            
            Graph()
                .frame(height: 80)
            
            HStack(spacing: 2) {
                if app.sensor != nil && (app.sensor.state != .unknown || app.sensor.serial != "") {
                    VStack(spacing: -4) {
                        Text(app.sensor.state.description)
                            .foregroundColor(app.sensor.state == .active ? .green : .red)
                        
                        if app.sensor.age > 0 {
                            Text(app.sensor.age.shortFormattedInterval)
                        }
                    }
                }
                
                if app.device != nil && (app.device.battery > -1 || app.device.rssi != 0) {
                    VStack(spacing: -4) {
                        if app.device.battery > -1 {
                            let battery = app.device.battery
                            
                            HStack(spacing: 4) {
                                let ext = battery > 95 ? 100 :
                                battery > 65 ? 75 :
                                battery > 35 ? 50 :
                                battery > 10 ? 25 : 0
                                
                                Image(systemName: "battery.\(ext)")
                                
                                Text("\(app.device.battery)%")
                            }
                            .foregroundColor(app.device.battery > 10 ? .green : .red)
                        }
                    }
                }
            }
            .footnote()
            .foregroundColor(.yellow)
            
            HStack {
                Button {
                    app.main.rescan()
                } label: {
                    Image(systemName: "arrow.clockwise.circle")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.blue)
                }
                .frame(height: 16)
                
                if (app.status.hasPrefix("Scanning") || app.status.hasSuffix("retrying...")) && app.main.centralManager.state != .poweredOff {
                    Button {
                        app.main.centralManager.stopScan()
                        app.main.status("Stopped scanning")
                        app.main.log("Bluetooth: stopped scanning")
                    } label: {
                        Image(systemName: "stop.circle")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.red)
                    }
                    .frame(height: 16)
                }
                
                NavigationLink {
                    Details()
                } label: {
                    Image(systemName: "info.circle")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.blue)
                }
                .frame(height: 16)
            }
            
            Text(app.status.hasPrefix("Scanning") ? app.status : app.status.replacingOccurrences(of: "\n", with: " "))
                .footnote()
                .lineLimit(app.status.hasPrefix("Scanning") ? 3 : 1)
                .truncationMode(app.status.hasPrefix("Scanning") ?.tail : .head)
                .frame(maxWidth: .infinity)
        }
        .navigationTitle("Monitor")
        .edgesIgnoringSafeArea(.bottom)
        .padding(.top, -26)
        .buttonStyle(.plain)
        .multilineTextAlignment(.center)
        .onAppear {
            if lastReadingDate != Date.distantPast {
                minutesSinceLastReading = Int(Date().timeIntervalSince(lastReadingDate) / 60)
            }
        }
        // TODO
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink {
                    HamburgerMenu()
                } label: {
                    Image(systemName: "line.horizontal.3")
                        .foregroundColor(.blue)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    settings.caffeinated.toggle()
                } label: {
                    Image(systemName: settings.caffeinated ? "cup.and.saucer.fill" : "cup.and.saucer")
                        .tint(.latte)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        Monitor()
    }
    .glucosyPreview()
}
