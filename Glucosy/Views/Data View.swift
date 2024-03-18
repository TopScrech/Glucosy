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
            
            HStack {
                VStack {
                    if history.values.count > 0 {
                        VStack(spacing: 4) {
                            Text("OOP history (values)")
                                .bold()
                            
                            ScrollView(showsIndicators: false) {
                                ForEach(history.values) { glucose in
                                    HStack {
                                        Text("\(glucose.id) \(glucose.date.shortDateTime)")
                                        
                                        Spacer()
                                        
                                        Text(glucose.value > -1 ? glucose.value.units : "   … ")
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
                            Text("History (factoryValues)")
                                .bold()
                            
                            ScrollView(showsIndicators: false) {
                                ForEach(history.factoryValues) { glucose in
                                    HStack {
                                        Text("\(glucose.id) \(glucose.date.shortDateTime)")
                                        
                                        Spacer()
                                        
                                        Text(glucose.value > -1 ? "  \(glucose.value.units)" : "   … ")
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
                        Text("Raw history (rawValues)")
                            .bold()
                        
                        ScrollView(showsIndicators: false) {
                            ForEach(history.rawValues) { glucose in
                                HStack {
                                    Text("\(glucose.id) \(glucose.date.shortDateTime)")
                                    
                                    Spacer()
                                    
                                    Text(glucose.value > -1 ? "  \(glucose.value.units)" : "   … ")
                                        .bold()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    .foregroundColor(.yellow)
                }
            }
            
            HStack {
                if history.factoryTrend.count > 0 {
                    VStack(spacing: 4) {
                        Text("Trend (factoryTrend)")
                            .bold()
                        
                        ScrollView(showsIndicators: false) {
                            ForEach(history.factoryTrend) { glucose in
                                HStack {
                                    Text("\(glucose.id) \(glucose.date.shortDateTime)")
                                    
                                    Spacer()
                                    
                                    Text(glucose.value > -1 ? glucose.value.units : "…")
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
                        Text("Raw trend (rawTrend)")
                            .bold()
                        
                        ScrollView(showsIndicators: false) {
                            ForEach(history.rawTrend) { glucose in
                                HStack {
                                    Text("\(glucose.id) \(glucose.date.shortDateTime)")
                                    
                                    Spacer()
                                    
                                    Text(glucose.value > -1 ? glucose.value.units : "…")
                                        .bold()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    .foregroundColor(.yellow)
                }
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
        .glucosyPreview(.data)
}
