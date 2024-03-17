import SwiftUI

struct DataView: View {
    @Environment(AppState.self) private var app: AppState
    @Environment(History.self) private var history: History
    @Environment(Log.self) private var log: Log
    @Environment(Settings.self) private var settings: Settings
    
    @State private var onlineCountdown = 0
    @State private var readingCountdown = 0
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
            VStack {
                Text("\((app.lastReadingDate != Date.distantPast ? app.lastReadingDate : Date()).dateTime)")
                
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
                
                VStack {
                    HStack {
                        VStack {
                            if history.values.count > 0 {
                                VStack(spacing: 4) {
                                    Text("OOP history")
                                        .bold()
                                    
                                    ScrollView {
                                        ForEach(history.values) { glucose in
                                            (Text("\(glucose.id) \(glucose.date.shortDateTime)") + Text(glucose.value > -1 ? "  \(glucose.value, specifier: "%3d")" : "   … ").bold())
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                                }
                                .foregroundColor(.blue)
                            }
                            
                            if history.factoryValues.count > 0 {
                                VStack(spacing: 4) {
                                    Text("History")
                                        .bold()
                                    
                                    ScrollView {
                                        ForEach(history.factoryValues) { glucose in
                                            (Text("\(glucose.id) \(glucose.date.shortDateTime)") + Text(glucose.value > -1 ? "  \(glucose.value, specifier: "%3d")" : "   … ").bold())
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                                }
                                .foregroundColor(.orange)
                            }
                        }
                        
                        if history.rawValues.count > 0 {
                            VStack(spacing: 4) {
                                Text("Raw history")
                                    .bold()
                                
                                ScrollView {
                                    ForEach(history.rawValues) { glucose in
                                        (Text("\(glucose.id) \(glucose.date.shortDateTime)") + Text(glucose.value > -1 ? "  \(glucose.value, specifier: "%3d")" : "   … ").bold())
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                            }
                            .foregroundColor(.yellow)
                        }
                    }
                    
                    HStack {
                        VStack {
                            if history.factoryTrend.count > 0 {
                                VStack(spacing: 4) {
                                    Text("Trend")
                                        .bold()
                                    
                                    ScrollView {
                                        ForEach(history.factoryTrend) { glucose in
                                            (Text("\(glucose.id) \(glucose.date.shortDateTime)") + Text(glucose.value > -1 ? "  \(glucose.value, specifier: "%3d")" : "   … ").bold())
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                                }
                                .foregroundColor(.orange)
                            }
                        }
                        
                        VStack {
                            if history.rawTrend.count > 0 {
                                VStack(spacing: 4) {
                                    Text("Raw trend")
                                        .bold()
                                    
                                    ScrollView {
                                        ForEach(history.rawTrend) { glucose in
                                            (Text("\(glucose.id) \(glucose.date.shortDateTime)") + Text(glucose.value > -1 ? "  \(glucose.value, specifier: "%3d")" : "   … ").bold())
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                                }
                                .foregroundColor(.yellow)
                            }
                        }
                    }
                    
                    HStack(spacing: 0) {
                        if history.storedValues.count > 0 {
                            VStack(spacing: 4) {
                                Text("HealthKit")
                                    .bold()
                                
                                List {
                                    ForEach(history.storedValues) { glucose in
                                        (Text("\(String(glucose.source[..<(glucose.source.lastIndex(of: " ") ?? glucose.source.endIndex)])) \(glucose.date.shortDateTime)") + Text("  \(glucose.value, specifier: "%3d")").bold())
                                            .fixedSize(horizontal: false, vertical: true)
                                            .listRowInsets(EdgeInsets())
                                            .listRowInsets(EdgeInsets())
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                            }
                            .foregroundColor(.red)
                                .onAppear {
                                    if let healthKit = app.main?.healthKit { 
                                        healthKit.readGlucose()
                                    }
                                }
                        }
                        
                        if history.nightscoutValues.count > 0 {
                            VStack(spacing: 4) {
                                Text("Nightscout")
                                    .bold()
                                
                                List {
                                    ForEach(history.nightscoutValues) { glucose in
                                        (Text("\(String(glucose.source[..<(glucose.source.lastIndex(of: " ") ?? glucose.source.endIndex)])) \(glucose.date.shortDateTime)") + Text("  \(glucose.value, specifier: "%3d")").bold())
                                            .fixedSize(horizontal: false, vertical: true)
                                            .listRowInsets(EdgeInsets())
                                    }
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                                }
                            }
                            .foregroundColor(.cyan)
                            .onAppear {
                                if let nightscout = app.main?.nightscout { 
                                    nightscout.read()
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
#if targetEnvironment(macCatalyst)
                .padding(.leading, 15)
#endif
            }
            .caption(design: .monospaced)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Data")
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
        .environment(AppState.test(tab: .data))
        .environment(Log())
        .environment(History.test)
        .environment(Settings())
}
