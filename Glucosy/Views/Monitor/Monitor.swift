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
            HStack {
                VStack {
                    if app.lastReadingDate != Date.distantPast {
                        Text(app.lastReadingDate.shortTime)
                            .monospacedDigit()
                        
                        Text("\(minutesSinceLastReading) min ago")
                            .footnote()
                            .monospacedDigit()
                            .onReceive(app.minuteTimer) { _ in
                                minutesSinceLastReading = Int(Date().timeIntervalSince(app.lastReadingDate) / 60)
                            }
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
                    .cornerRadius(8)
                
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
                .frame(height: 400)
                .padding(.horizontal)
            
            //            Text("values: \(Double(history.values.last?.value ?? 0) / 18.0182)")
            //            Text("factoryValues: \(Double(history.factoryValues.last?.value ?? 0) / 18.0182)") // orange
            //            Text("rawValues: \(Double(history.rawValues.last?.value ?? 0) / 18.0182)")         // yellow
            //            Text("factoryTrend: \(Double(history.factoryTrend.last?.value ?? 0)   / 18.0182)")
            //            Text("rawTrend: \(Double(history.rawTrend.last?.value ?? 0)           / 18.0182)")
            //            Text("glucose: \(Double(history.glucose.last?.value ?? 0)   / 18.0182)")
            //
            //            let factoryValues = history.factoryValues.map(\.value).map {
            //                Double($0) / 18.0182
            //            }
            
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
                
                let battery = app.device.battery
                let rssi = app.device.rssi
                
                if app.device != nil && (battery > -1 || rssi != 0) {
                    VStack {
                        if battery > -1 {
                            let battery = battery
                            
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
            
            NavigationLink(destination: Details()) {
                Text("Details")
                    .footnote(.bold)
                    .fixedSize()
                    .padding(.horizontal, 4)
                    .padding(2)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.accentColor, lineWidth: 2)
                    }
            }
            
            Spacer()
            
            Spacer()
            
            HStack {
                Button {
                    app.main.rescan()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .title()
                }
                
                if (app.status.hasPrefix("Scanning") || app.status.hasSuffix("retrying...")) && app.main.centralManager.state != .poweredOff {
                    Button {
                        app.main.centralManager.stopScan()
                        
                        app.main.status("Stopped scanning")
                        app.main.log("Bluetooth: stopped scanning")
                    } label: {
                        Image(systemName: "stop.circle")
                            .title()
                    }
                    .foregroundColor(.red)
                }
            }
            .padding(.bottom, 8)
        }
        .navigationTitle("Monitor")
        .multilineTextAlignment(.center)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if app.lastReadingDate != Date.distantPast {
                minutesSinceLastReading = Int(Date().timeIntervalSince(app.lastReadingDate) / 60)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    settings.caffeinated.toggle()
                    UIApplication.shared.isIdleTimerDisabled = settings.caffeinated
                } label: {
                    Image(systemName: settings.caffeinated ? "cup.and.saucer.fill" : "cup.and.saucer")
                        .tint(.latte)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
#if DEBUG
                Menu {
                    Button {
                        history.factoryValues = History.test.factoryValues
                        history.rawValues = History.test.rawValues
                        history.glucose = History.test.glucose
                        app.currentGlucose = Int.random(in: 1...10)
                        
                        UserDefaults(suiteName: "group.dev.topscrech.Health-Point")!.setValue("\(Int.random(in: 1...10))", forKey: "currentGlucose")
                        UserDefaults(suiteName: "group.dev.topscrech.Health-Point")!.setValue(Date().timeIntervalSinceReferenceDate, forKey: "widgetDate")
                        WidgetCenter.shared.reloadAllTimelines()
                    } label: {
                        Label("Test", systemImage: "hammer")
                    }
                    
                } label: {
                    Image(systemName: "sensor.tag.radiowaves.forward.fill")
                    
                } primaryAction: {
                    app.main.nfc.startSession()
                }
#else
                SFButton("sensor.tag.radiowaves.forward.fill") {
                    app.main.nfc.startSession()
                }
#endif
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
