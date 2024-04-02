import SwiftUI
import Charts

struct OnlineView: View {
    @Environment(AppState.self) var app: AppState
    @Environment(History.self)  var history: History
    @Environment(Settings.self) var settings: Settings
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var onlineCountdown = 0
    @State private var readingCountdown = 0
    
    @State var libreLinkUpResponse = "[...]"
    @State var libreLinkUpHistory:        [LibreLinkUpGlucose] = []
    @State var libreLinkUpLogbookHistory: [LibreLinkUpGlucose] = []
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                Button {
                    settings.selectedService.toggle()
                } label: {
                    Image(selectedService.rawValue)
                        .resizable()
                        .frame(width: 32, height: 32)
                        .shadow(color: .cyan, radius: 4)
                }
                .padding(.top, 8)
                .padding(.trailing, 4)
                
                VStack(spacing: 0) {
                    @Bindable var settings = settings
                    
                    if selectedService == .nightscout {
                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                            Text("https://")
                                .foregroundColor(Color(.lightGray))
                            
                            TextField("Nightscout URL", text: $settings.nightscoutSite)
                                .keyboardType(.URL)
                                .textContentType(.URL)
                                .autocorrectionDisabled(true)
                        }
                        
                        HStack(alignment: .firstTextBaseline) {
                            Text("token:")
                                .foregroundColor(Color(.lightGray))
                            
                            SecureField("token", text: $settings.nightscoutToken)
                        }
                        
                    } else if selectedService == .libreLinkUp {
                        TextField("email", text: $settings.libreLinkUpEmail)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .onSubmit {
                                settings.libreLinkUpPatientId = ""
                                libreLinkUpResponse = "[Logging in...]"
                                
                                Task {
                                    await reloadLLU()
                                }
                            }
                        
                        SecureField("password", text: $settings.libreLinkUpPassword)
                            .onSubmit {
                                settings.libreLinkUpPatientId = ""
                                libreLinkUpResponse = "[Logging in...]"
                                
                                Task {
                                    await reloadLLU()
                                }
                            }
                    }
                }
                
                Button {
                    withAnimation {
                        settings.libreLinkUpFollowing.toggle()
                    }
                    
                    libreLinkUpResponse = "[...]"
                    
                    Task {
                        await reloadLLU()
                    }
                } label: {
                    Image(systemName: settings.libreLinkUpFollowing ? "f.circle.fill" : "f.circle")
                        .title()
                        .foregroundColor(.blue)
                }
                
                VStack(spacing: 0) {
                    Button {
                        withAnimation {
                            settings.libreLinkUpScrapingLogbook.toggle()
                        }
                        
                        if settings.libreLinkUpScrapingLogbook {
                            libreLinkUpResponse = "[...]"
                            
                            Task {
                                await reloadLLU()
                            }
                        }
                    } label: {
                        Image(systemName: settings.libreLinkUpScrapingLogbook ? "book.closed.fill" : "book.closed")
                            .title()
                            .foregroundColor(.blue)
                    }
                    
                    Text(onlineCountdown > -1 ? "\(onlineCountdown) s" : "...")
                        .fixedSize()
                        .foregroundColor(.cyan)
                        .caption()
                        .monospacedDigit()
                        .onReceive(app.secondTimer) { _ in
                            onlineCountdown = settings.onlineInterval * 60 - Int(Date().timeIntervalSince(settings.lastOnlineDate))
                        }
                }
                
                Spacer()
                
                VStack(spacing: 0) {
                    // TODO: reload web page
                    
                    Button {
                        app.main.rescan()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .title()
                            .foregroundColor(.accentColor)
                    }
                    
                    Text(!app.deviceState.isEmpty && app.deviceState != "Disconnected" && (readingCountdown > 0 || app.deviceState == "Reconnecting...") ?
                         "\(readingCountdown) s" : "...")
                    .fixedSize()
                    .foregroundColor(.orange)
                    .caption()
                    .monospacedDigit()
                    .onReceive(app.secondTimer) { _ in
                        readingCountdown = settings.readingInterval * 60 - Int(Date().timeIntervalSince(app.lastConnectionDate))
                    }
                }
            }
            .foregroundColor(.accentColor)
            .padding(.bottom, 4)
            //#if targetEnvironment(macCatalyst)
            .padding(.horizontal, 15)
            //#endif
            if selectedService == .nightscout {
                @Bindable var app = app
                
                WebView(site: settings.nightscoutSite, query: "token=\(settings.nightscoutToken)", delegate: app.main?.nightscout )
                    .frame(height: UIScreen.main.bounds.size.height * 0.60)
                    .alert("JavaScript", isPresented: $app.alertJSConfirm) {
                        Button("OK") {
                            app.main.log("JavaScript alert: selected OK")
                        }
                        
                        Button("Cancel", role: .cancel) {
                            app.main.log("JavaScript alert: selected Cancel")
                        }
                    } message: {
                        Text(app.jsConfirmAlertMessage)
                    }
                
                List {
                    ForEach(history.nightscoutValues, id: \.self) { glucose in
                        (Text("\(String(glucose.source[..<(glucose.source.lastIndex(of: " ") ?? glucose.source.endIndex)])) \(glucose.date.shortDateTime)") + Text("  \(glucose.value, specifier: "%3d")").bold())
                            .fixedSize(horizontal: false, vertical: true)
                            .listRowInsets(EdgeInsets())
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .listStyle(.plain)
                .caption(design: .monospaced)
                .foregroundColor(.cyan)
#if targetEnvironment(macCatalyst)
                .padding(.leading, 15)
#endif
                .onAppear {
                    if let nightscout = app.main?.nightscout {
                        nightscout.read()
                    }
                }
            }
            
            if selectedService == .libreLinkUp {
                VStack {
                    ScrollView(showsIndicators: true) {
                        Text(libreLinkUpResponse)
                            .footnote(design: .monospaced)
                            .foregroundColor(colorScheme == .dark ? Color(.lightGray) : Color(.darkGray))
                            .textSelection(.enabled)
                    }
#if targetEnvironment(macCatalyst)
                    .padding()
#endif
                    if libreLinkUpHistory.count > 0 {
                        Chart(libreLinkUpHistory) {
                            PointMark(
                                x: .value("Time", $0.glucose.date),
                                y: .value("Glucose", $0.glucose.value)
                            )
                            .foregroundStyle($0.color.color)
                            .symbolSize(12)
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .hour, count: 3)) { _ in
                                AxisGridLine()
                                
                                AxisTick()
                                
                                AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .omitted)).minute(), anchor: .top)
                            }
                        }
                        .padding()
                    }
                    
                    HStack {
                        List {
                            ForEach(libreLinkUpHistory) { lluGlucose in
                                let glucose = lluGlucose.glucose
                                (Text("\(String(glucose.source[..<(glucose.source.lastIndex(of: " ") ?? glucose.source.endIndex)])) \(glucose.date.shortDateTime)") + Text("  \(glucose.value, specifier: "%3d") ").bold() + Text(lluGlucose.trendArrow?.symbol ?? "").font(.subheadline))
                                    .foregroundColor(lluGlucose.color.color)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .listRowInsets(EdgeInsets())
                            }
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                        }
                        // TODO: respect onlineInterval
                        
                        .onReceive(app.minuteTimer) { _ in
                            Task {
                                app.main.debugLog("DEBUG: fired onlineView minuteTimer: timeInterval: \(Int(Date().timeIntervalSince(settings.lastOnlineDate)))")
                                
                                if settings.onlineInterval > 0 && Int(Date().timeIntervalSince(settings.lastOnlineDate)) >= settings.onlineInterval * 60 - 5 {
                                    
                                    await reloadLLU()
                                }
                            }
                        }
                        
                        if settings.libreLinkUpScrapingLogbook {
                            // TODO: alarms
                            
                            List {
                                ForEach(libreLinkUpLogbookHistory) { lluGlucose in
                                    let glucose = lluGlucose.glucose
                                    (Text("\(String(glucose.source[..<(glucose.source.lastIndex(of: " ") ?? glucose.source.endIndex)])) \(glucose.date.shortDateTime)") + Text("  \(glucose.value, specifier: "%3d") ").bold() + Text(lluGlucose.trendArrow!.symbol).font(.subheadline))
                                        .foregroundColor(lluGlucose.color.color)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .listRowInsets(EdgeInsets())
                                }
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .caption()
                    .monospaced()
                }
                .task {
                    await reloadLLU()
                }
#if targetEnvironment(macCatalyst)
                .padding(.leading, 15)
#endif
            }
        }
        .standardToolbar()
        .navigationTitle("Online")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    HomeView()
        .glucosyPreview(.online)
}
