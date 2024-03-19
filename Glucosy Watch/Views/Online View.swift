import SwiftUI
import Charts

struct OnlineView: View {
    @Environment(AppState.self) private var app: AppState
    @Environment(History.self) private var history: History
    @Environment(Settings.self) private var settings: Settings
    
    @State private var onlineCountdown = 0
    @State private var readingCountdown = 0
    
    @State private var libreLinkUpResponse = "[...]"
    @State private var libreLinkUpHistory: [LibreLinkUpGlucose] = []
    @State private var libreLinkUpLogbookHistory: [LibreLinkUpGlucose] = []
    @State private var showingCredentials = false
        
    func reloadLibreLinkUp() async {
        if let libreLinkUp = await app.main?.libreLinkUp {
            var dataString = ""
            var retries = 0
        loop: repeat {
            do {
                if settings.libreLinkUpPatientId.isEmpty ||
                    settings.libreLinkUpToken.isEmpty ||
                    settings.libreLinkUpTokenExpirationDate < Date() ||
                    retries == 1 {
                    
                    do {
                        try await libreLinkUp.login()
                    } catch {
                        libreLinkUpResponse = error.localizedDescription.capitalized
                    }
                }
                
                if !(settings.libreLinkUpPatientId.isEmpty ||
                     settings.libreLinkUpToken.isEmpty) {
                    let (data, _, graphHistory, logbookData, logbookHistory, _) = try await libreLinkUp.getPatientGraph()
                    dataString = (data as! Data).string
                    libreLinkUpResponse = dataString + (logbookData as! Data).string
                    // TODO: just merge with newer values
                    libreLinkUpHistory = graphHistory.reversed()
                    libreLinkUpLogbookHistory = logbookHistory
                    
                    if graphHistory.count > 0 {
                        DispatchQueue.main.async {
                            settings.lastOnlineDate = Date()
                            let lastMeasurement = libreLinkUpHistory[0]
                            app.lastReadingDate = lastMeasurement.glucose.date
                            app.sensor?.lastReadingDate = app.lastReadingDate
                            app.currentGlucose = lastMeasurement.glucose.value
                            // TODO: keep the raw values filling the gaps with -1 values
                            history.rawValues = []
                            history.factoryValues = libreLinkUpHistory.dropFirst().map(\.glucose) // TEST
                            var trend = history.factoryTrend
                            
                            if trend.isEmpty || lastMeasurement.id > trend[0].id {
                                trend.insert(lastMeasurement.glucose, at: 0)
                            }
                            
                            // keep only the latest 22 minutes considering the 17-minute latency of the historic values update
                            trend = trend.filter {
                                lastMeasurement.id - $0.id < 22
                            }
                            
                            history.factoryTrend = trend
                            // TODO: merge and update sensor history / trend
                            app.main.didParseSensor(app.sensor)
                        }
                    }
                    
                    if dataString != "{\"message\":\"MissingCachedUser\"}\n" {
                        break loop
                    }
                    
                    retries += 1
                }
            } catch {
                libreLinkUpResponse = error.localizedDescription.capitalized
            }
        } while retries == 1
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    settings.selectedService = settings.selectedService == .nightscout ? .libreLinkUp : .nightscout
                } label: {
                    Image(settings.selectedService.rawValue)
                        .resizable()
                        .frame(width: 32, height: 32)
                        .shadow(color: .cyan, radius: 4)
                }
                
                VStack(spacing: 0) {
                    Text("\(settings.selectedService.rawValue)")
                        .foregroundColor(.accentColor)
                    
                    HStack {
                        Button {
                            withAnimation {
                                showingCredentials.toggle()
                            }
                        } label: {
                            Image(systemName: showingCredentials ? "person.crop.circle.fill" : "person.crop.circle")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.blue)
                        }
                        
                        Button {
                            withAnimation {
                                settings.libreLinkUpScrapingLogbook.toggle()
                            }
                            
                            if settings.libreLinkUpScrapingLogbook {
                                libreLinkUpResponse = "[...]"
                                Task {
                                    await reloadLibreLinkUp()
                                }
                            }
                        } label: {
                            Image(systemName: settings.libreLinkUpScrapingLogbook ? "book.closed.circle.fill" : "book.closed.circle")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.blue)
                        }
                        
                        Text(onlineCountdown > -1 ? "\(onlineCountdown) s" : "...")
                            .fixedSize()
                            .foregroundColor(.cyan)
                            .footnote()
                            .monospacedDigit()
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
                .frame(maxWidth: .infinity)
                
                VStack(spacing: 0) {
                    Button {
                        app.main.rescan()
                    } label: {
                        Image(systemName: "arrow.clockwise.circle")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.blue)
                    }
                    
                    Text(app.deviceState != "Disconnected" && (readingCountdown > 0 || app.deviceState == "Reconnecting...") ?
                         "\(readingCountdown) s" : "...")
                    .fixedSize()
                    .foregroundColor(.orange)
                    .footnote()
                    .monospacedDigit()
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
            
            if showingCredentials {
                @Bindable var settings = settings
                
                HStack {
                    if settings.selectedService == .nightscout {
                        TextField("Nightscout URL", text: $settings.nightscoutSite)
                            .textContentType(.URL)
                        
                        SecureField("token", text: $settings.nightscoutToken)
                        
                    } else if settings.selectedService == .libreLinkUp {
                        TextField("email", text: $settings.libreLinkUpEmail)
                            .textContentType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .onSubmit {
                                settings.libreLinkUpPatientId = ""
                                libreLinkUpResponse = "[Logging in...]"
                                
                                Task {
                                    await reloadLibreLinkUp()
                                }
                            }
                        
                        SecureField("password", text: $settings.libreLinkUpPassword)
                            .onSubmit {
                                settings.libreLinkUpPatientId = ""
                                libreLinkUpResponse = "[Logging in...]"
                                
                                Task {
                                    await reloadLibreLinkUp()
                                }
                            }
                    }
                }
                .footnote()
                
                Toggle("Follower", isOn: $settings.libreLinkUpFollowing)
                    .onChange(of: settings.libreLinkUpFollowing) {
                        settings.libreLinkUpPatientId = ""
                        libreLinkUpResponse = "[Logging in...]"
                        
                        Task {
                            await reloadLibreLinkUp()
                        }
                    }
            }
            
            if settings.selectedService == .nightscout {
                ScrollView(showsIndicators: true) {
                    VStack(spacing: 0) {
                        if history.nightscoutValues.count > 0 {
                            let twelveHours = Double(12 * 60 * 60)  // TODO: the same as LLU
                            let now = Date()
                            
                            let nightscoutHistory = history.nightscoutValues.filter {
                                now.timeIntervalSince($0.date) <= twelveHours
                            }
                            
                            Chart(nightscoutHistory, id: \.self) {
                                PointMark(
                                    x: .value("Time", $0.date),
                                    y: .value("Glucose", $0.value)
                                )
                                .foregroundStyle(.cyan)
                                .symbolSize(6)
                            }
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .hour, count: 3)) { _ in
                                    AxisGridLine()
                                    
                                    AxisTick()
                                    
                                    AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .omitted)).minute(), anchor: .top)
                                }
                            }
                            .padding()
                            .frame(maxHeight: 64)
                        }
                        
                        List {
                            ForEach(history.nightscoutValues, id: \.self) { glucose in
                                (Text("\(String(glucose.source[..<(glucose.source.lastIndex(of: " ") ?? glucose.source.endIndex)])) \(glucose.date.shortDateTime)") + Text("  \(glucose.value, specifier: "%3d")").bold())
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                        }
                        .frame(minHeight: 64)
                    }
                }
                // .footnote(design: .monospaced)
                .foregroundColor(.cyan)
                .onAppear {
                    if let nightscout = app.main?.nightscout {
                        nightscout.read()
                        app.main.log("nightscoutValues count \(history.nightscoutValues.count)")
                    }
                }
            }
            
            if settings.selectedService == .libreLinkUp {
                ScrollView(showsIndicators: true) {
                    VStack(spacing: 0) {
                        if libreLinkUpHistory.count > 0 {
                            Chart(libreLinkUpHistory) {
                                PointMark(
                                    x: .value("Time", $0.glucose.date),
                                    y: .value("Glucose", $0.glucose.value)
                                )
                                .foregroundStyle($0.color.color)
                                .symbolSize(6)
                            }
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .hour, count: 3)) { _ in
                                    AxisGridLine()
                                    
                                    AxisTick()
                                    
                                    AxisValueLabel(
                                        format: .dateTime.hour(.defaultDigits(amPM: .omitted)).minute(),
                                        anchor: .top
                                    )
                                }
                            }
                            .padding()
                            .frame(maxHeight: 64)
                        }
                        
                        HStack {
                            List {
                                ForEach(libreLinkUpHistory) { lluGlucose in
                                    let glucose = lluGlucose.glucose
                                    
                                    (Text("\(!settings.libreLinkUpScrapingLogbook ? String(glucose.source[..<(glucose.source.lastIndex(of: " ") ?? glucose.source.endIndex)]) + " " : "")\(glucose.date.shortDateTime)") + Text("  \(glucose.value, specifier: "%3d") ").bold() + Text(lluGlucose.trendArrow?.symbol ?? "").font(.title3))
                                        .foregroundColor(lluGlucose.color.color)
                                        .padding(.vertical, 1)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                            }
                            // TODO: respect onlineInterval
                            .onReceive(app.minuteTimer) { _ in
                                Task {
                                    app.main.debugLog("DEBUG: fired onlineView minuteTimer: timeInterval: \(Int(Date().timeIntervalSince(settings.lastOnlineDate)))")
                                    
                                    if settings.onlineInterval > 0 && Int(Date().timeIntervalSince(settings.lastOnlineDate)) >= settings.onlineInterval * 60 - 5 {
                                        
                                        await reloadLibreLinkUp()
                                    }
                                }
                            }
                            
                            if settings.libreLinkUpScrapingLogbook {
                                // TODO: alarms
                                List {
                                    ForEach(libreLinkUpLogbookHistory) { lluGlucose in
                                        let glucose = lluGlucose.glucose
                                        (Text("\(glucose.date.shortDateTime)") + Text("  \(glucose.value, specifier: "%3d") ").bold() + Text(lluGlucose.trendArrow!.symbol).font(.title3))
                                            .foregroundColor(lluGlucose.color.color)
                                            .padding(.vertical, 1)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                                }
                            }
                        }
                        // .footnote(design: .monospaced)
                        .frame(minHeight: 64)
                        
                        Text(libreLinkUpResponse)
                            .footnote()
                            .foregroundColor(Color(.lightGray))
                        // .footnote(design: .monospaced)
                        // .foregroundColor(Color(.lightGray))
                    }
                }
                .task {
                    await reloadLibreLinkUp()
                }
            }
        }
        .padding(.top, -4)
        .edgesIgnoringSafeArea([.bottom])
        .buttonStyle(.plain)
        .navigationTitle("Online")
        .tint(.blue)
    }
}

#Preview {
    OnlineView()
        .glucosyPreview(.online)
}
