import SwiftUI

struct DataView: View {
    @Environment(AppState.self) private var app: AppState
    @Environment(History.self)  private var history: History
    @Environment(Settings.self) private var settings: Settings
    @Environment(Log.self)      private var log: Log
    
    @State private var onlineCountdown = 0
    @State private var readingCountdown = 0
    
    var body: some View {
        ScrollView {
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
            
            if history.factoryTrend.count + history.rawTrend.count > 0 {
                HStack {
                    if history.factoryTrend.count > 0 {
                        VStack(spacing: 4) {
                            Text("Trend")
                                .bold()
                            
                            List {
                                ForEach(history.factoryTrend, id: \.self) { glucose in
                                    HStack {
                                        Text("\(glucose.id) \(glucose.date.shortDateTime)")
                                        
                                        Spacer()
                                        
                                        Text(glucose.value > -1 ? "  \(glucose.value, specifier: "%3d")" : "   … ")
                                            .bold()
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                        }
                        .foregroundColor(.orange)
                    }
                    
                    if history.rawTrend.count > 0 {
                        VStack(spacing: 4) {
                            Text("Raw trend")
                                .bold()
                            
                            List {
                                ForEach(history.rawTrend, id: \.self) { glucose in
                                    HStack {
                                        Text("\(glucose.id) \(glucose.date.shortDateTime)")
                                        
                                        Spacer()
                                        
                                        Text(glucose.value > -1 ? "  \(glucose.value, specifier: "%3d")" : "   … ")
                                            .bold()
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                        }
                        .foregroundColor(.yellow)
                    }
                }
                .frame(idealHeight: 300)
            }
            
            HStack {
                if history.healthKitGlucose.count > 0 {
                    VStack(spacing: 4) {
                        Text("HealthKit")
                            .bold()
                        
                        List {
                            ForEach(history.healthKitGlucose, id: \.self) { glucose in
                                HStack {
                                    Text("\(String(glucose.source[..<(glucose.source.lastIndex(of: " ") ?? glucose.source.endIndex)])) \(glucose.date.shortDateTime)")
                                    
                                    Spacer()
                                    
                                    Text(glucose.value.units)
                                        .bold()
                                }
                                .monospacedDigit()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    .foregroundColor(.red)
                    .onAppear {
                        app.main.healthKit?.readGlucose()
                    }
                }
                
                if history.nightscoutValues.count > 0 {
                    VStack(spacing: 4) {
                        Text("Nightscout")
                            .bold()
                        
                        List {
                            ForEach(history.nightscoutValues, id: \.self) { glucose in
                                HStack {
                                    Text("\(String(glucose.source[..<(glucose.source.lastIndex(of: " ") ?? glucose.source.endIndex)])) \(glucose.date.shortDateTime)")
                                    
                                    Spacer()
                                    
                                    Text("  \(glucose.value, specifier: "%3d")")
                                        .bold()
                                }
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
            .frame(idealHeight: 300)
            
            HStack {
                VStack {
                    if history.values.count > 0 {
                        VStack(spacing: 4) {
                            Text("OOP history")
                                .bold()
                            
                            List {
                                ForEach(history.values, id: \.self) { glucose in
                                    HStack {
                                        Text("\(glucose.id) \(glucose.date.shortDateTime)")
                                        
                                        Spacer()
                                        
                                        Text(glucose.value > -1 ? "  \(glucose.value, specifier: "%3d")" : "   … ")
                                            .bold()
                                    }
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
                            
                            List {
                                ForEach(history.factoryValues, id: \.self) { glucose in
                                    HStack {
                                        Text("\(glucose.id) \(glucose.date.shortDateTime)")
                                        
                                        Spacer()
                                        
                                        Text(glucose.value > -1 ? "  \(glucose.value, specifier: "%3d")" : "   … ")
                                            .bold()
                                    }
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
                        
                        List {
                            ForEach(history.rawValues, id: \.self) { glucose in
                                HStack {
                                    Text("\(glucose.id) \(glucose.date.shortDateTime)")
                                    
                                    Spacer()
                                    
                                    Text(glucose.value > -1 ? "  \(glucose.value, specifier: "%3d")" : "   … ")
                                        .bold()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    .foregroundColor(.yellow)
                }
            }
            .frame(idealHeight: 300)
        }
        .navigationTitle("Data")
        .padding(.top, -4)
        .edgesIgnoringSafeArea([.bottom])
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .footnote()
        //        .monospaced()
        //        .foregroundColor(Color(.lightGray))
        .tint(.blue)
    }
}

#Preview {
    DataView()
        .glucosyPreview(.data)
}
