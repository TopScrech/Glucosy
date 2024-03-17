import ScrechKit

struct Monitor: View {
    @Environment(AppState.self) private var app: AppState
    @Environment(Log.self) private var log: Log
    @Environment(History.self) private var history: History
    @Environment(Settings.self) private var settings: Settings
    
    @State private var showingNFCAlert = false
    
    @State private var readingCountdown = 0
    @State private var minutesSinceLastReading = 0
    
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var minuteTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                HStack {
                    VStack {
                        if app.lastReadingDate != Date.distantPast {
                            Text(app.lastReadingDate.shortTime)
                                .monospacedDigit()
                            
                            Text("\(minutesSinceLastReading) min ago")
                                .footnote()
                                .monospacedDigit()
                                .onReceive(minuteTimer) { _ in
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
                    
                    Text(app.currentGlucose > 0 ? "\(app.currentGlucose.units) " : "--- ")
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
                        .onReceive(timer) { _ in
                            readingCountdown = settings.readingInterval * 60 - Int(Date().timeIntervalSince(app.lastConnectionDate))
                        }
                    }
                }
            }
            
            Graph()
                .frame(height: 200)
                .padding(.horizontal)
            
            //            Text("values: \(Double(history.values.last?.value ?? 0) / 18.0182)")
            //            Text("factoryValues: \(Double(history.factoryValues.last?.value ?? 0) / 18.0182)") // orange
            //            Text("rawValues: \(Double(history.rawValues.last?.value ?? 0) / 18.0182)")         // yellow
            //            Text("factoryTrend: \(Double(history.factoryTrend.last?.value ?? 0) / 18.0182)")
            //            Text("rawTrend: \(Double(history.rawTrend.last?.value ?? 0) / 18.0182)")
            //            Text("storedValues: \(Double(history.storedValues.last?.value ?? 0) / 18.0182)")
            //
            //            let factoryValues = history.factoryValues.map(\.value).map {
            //                Double($0) / 18.0182
            //            }
            
            VStack {
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
                                    
                                    Text("\(app.device.battery)%")
                                }
                                .foregroundColor(app.device.battery > 10 ? .green : .red)
                            }
                            
                            if app.device.rssi != 0 {
                                Text("RSSI: ")
                                    .foregroundColor(Color(.lightGray)) +
                                
                                Text("\(app.device.rssi) dB")
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
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.accentColor, lineWidth: 2))
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
        .multilineTextAlignment(.center)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Monitor")
        .onAppear {
            timer =         Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            minuteTimer =   Timer.publish(every: 60, on: .main, in: .common).autoconnect()
            
            if app.lastReadingDate != Date.distantPast {
                minutesSinceLastReading = Int(Date().timeIntervalSince(app.lastReadingDate) / 60)
            }
        }
        .onDisappear {
            timer.upstream.connect().cancel()
            minuteTimer.upstream.connect().cancel()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    settings.caffeinated.toggle()
                    UIApplication.shared.isIdleTimerDisabled = settings.caffeinated
                } label: {
                    Image(systemName: settings.caffeinated ? "cup.and.saucer.fill" : "cup.and.saucer")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                SFButton("sensor.tag.radiowaves.forward.fill") {
                    if app.main.nfc.isAvailable {
                        app.main.nfc.startSession()
                    } else {
                        showingNFCAlert = true
                    }
                }
            }
        }
        .alert("NFC not supported", isPresented: $showingNFCAlert) {
            
        } message: {
            Text("This device doesn't allow scanning the Libre.")
        }
    }
}

#Preview {
    NavigationView {
        Monitor()
    }
    .glucosyPreview()
}
