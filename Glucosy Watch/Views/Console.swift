import SwiftUI

struct Console: View {
    @Environment(AppState.self) private var app: AppState
    @Environment(Log.self) private var log: Log
    @Environment(Settings.self) private var settings: Settings
    
    @State private var onlineCountdown = 0
    @State private var readingCountdown = 0
    
    @State private var showingFilterField = false
    @State private var filterText = ""
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                if showingFilterField {
                    ScrollView {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color(.lightGray))
                            
                            TextField("Filter", text: $filterText)
                                .foregroundColor(.blue)
                                .textInputAutocapitalization(.never)
                            
                            if filterText.count > 0 {
                                Button {
                                    filterText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                }
                                .frame(maxWidth: 24)
                                .padding(0)
                                .buttonStyle(.plain)
                                .foregroundColor(.blue)
                            }
                        }
                        
                        // TODO: picker to filter labels
                        ForEach(Array(log.labels), id: \.self) { label in
                            Button {
                                filterText = label
                            } label: {
                                Text(label)
                                    .caption()
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: true) {
                        LazyVStack(alignment: .leading, spacing: 10) {
                            if filterText.isEmpty {
                                ForEach(log.entries) { entry in
                                    Text(entry.message)
                                }
                            } else {
                                let pattern = filterText.lowercased()
                                
                                ForEach(log.entries.filter { $0.message.lowercased().contains(pattern) }) { entry in
                                    Text(entry.message)
                                }
                            }
                        }
                    }
                    // .footnote(design: .monospaced)
                    // .foregroundColor(Color(.lightGray))
                    .footnote()
                    .foregroundColor(Color(.lightGray))
                    .onChange(of: log.entries.count) {
                        if !settings.reversedLog {
                            withAnimation {
                                proxy.scrollTo(log.entries.last!.id, anchor: .bottom)
                            }
                        } else {
                            withAnimation {
                                proxy.scrollTo(log.entries[0].id, anchor: .top)
                            }
                        }
                    }
                    .onChange(of: log.entries[0].id) {
                        if !settings.reversedLog {
                            withAnimation {
                                proxy.scrollTo(log.entries.last!.id, anchor: .bottom)
                            }
                        } else {
                            withAnimation {
                                proxy.scrollTo(log.entries[0].id, anchor: .top)
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        withAnimation {
                            showingFilterField.toggle()
                        }
                    } label: {
                        Image(systemName: filterText.isEmpty ? "line.horizontal.3.decrease.circle" : "line.horizontal.3.decrease.circle.fill")
                            .title3()
                        
                        Text("Filter")
                    }
                }
            }
            .buttonStyle(.plain)
            .foregroundColor(.blue)
            
            HStack(alignment: .center, spacing: 0) {
                VStack(spacing: 0) {
                    Button {
                        app.main.rescan()
                    } label: {
                        VStack {
                            Image(.bluetooth)
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                    }
                }
                .foregroundColor(.blue)
                
                if (app.status.hasPrefix("Scanning") || app.status.hasSuffix("retrying...")) && app.main.centralManager.state != .poweredOff {
                    Button {
                        app.main.centralManager.stopScan()
                        app.main.status("Stopped scanning")
                        app.main.log("Bluetooth: stopped scanning")
                    } label: {
                        Image(systemName: "octagon")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .overlay(
                                Image(systemName: "hand.raised.fill")
                                .resizable()
                                .frame(width: 12, height: 12)
                                .offset(x: 1)
                            )
                    }
                    .foregroundColor(.red)
                    
                } else if app.deviceState == "Connected" || app.deviceState == "Reconnecting..." || app.status.hasSuffix("retrying...") {
                    Button {
                        if app.device != nil {
                            app.main.bluetoothDelegate.knownDevices[app.device.peripheral!.identifier.uuidString]!.isIgnored = true
                            app.main.centralManager.cancelPeripheralConnection(app.device.peripheral!)
                        }
                    } label: {
                        Image(systemName: "escape")
                            .resizable()
                            .padding(3)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                    }
                    
                } else {
                    Image(systemName: "octagon")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .hidden()
                }
                
                if onlineCountdown <= 0 && !app.deviceState.isEmpty && app.deviceState != "Disconnected" {
                    VStack(spacing: 0) {
                        Text(readingCountdown > 0 || app.deviceState == "Reconnecting..." ?
                             "\(readingCountdown)" : " ")
                        
                        Text(readingCountdown > 0 || app.deviceState == "Reconnecting..." ?
                             "s" : " ")
                    }
                    .footnote()
                    .monospacedDigit()
                    .foregroundColor(.orange)
                    .frame(width: 24, height: 24)
                    .allowsTightening(true)
                    .fixedSize()
                    .onReceive(timer) { _ in
                        // workaround: watchOS fails converting the interval to an Int32
                        if app.lastConnectionDate == Date.distantPast {
                            readingCountdown = 0
                        } else {
                            readingCountdown = settings.readingInterval * 60 - Int(Date().timeIntervalSince(app.lastConnectionDate))
                        }
                    }
                } else {
                    Spacer()
                }
                
                Text(onlineCountdown > 0 ? "\(onlineCountdown) s" : "")
                    .fixedSize()
                    .foregroundColor(.cyan)
                    .footnote()
                    .monospacedDigit()
                    .onReceive(timer) { _ in
                        // workaround: watchOS fails converting the interval to an Int32
                        if settings.lastOnlineDate == Date.distantPast {
                            onlineCountdown = 0
                        } else {
                            onlineCountdown = settings.onlineInterval * 60 - Int(Date().timeIntervalSince(settings.lastOnlineDate))
                        }
                    }
                
                Spacer()
                
                Button {
                    settings.userLevel = UserLevel(rawValue:(settings.userLevel.rawValue + 1) % UserLevel.allCases.count)!
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5).fill(settings.userLevel != .basic ? .blue : .clear)
                        
                        Image(systemName: ["doc.plaintext", "ladybug", "testtube.2"][settings.userLevel.rawValue])
                            .resizable()
                            .frame(width: 22, height: 22)
                            .foregroundColor(settings.userLevel != .basic ? .black : .blue)
                    }
                    .frame(width: 24, height: 24)
                }
                
                //                      Button {
                //                          UIPasteboard.general.string = log.entries.map(\.message).joined(separator: "\n \n")
                //                      } label: {
                //                          VStack {
                //                              Image(systemName: "doc.on.doc")
                //                                  .resizable()
                //                                  .frame(width: 24, height: 24)
                //
                //                              Text("Copy")
                //                                  .offset(y: -6)
                //                          }
                //                      }
                
                Button {
                    log.entries = [LogEntry(message: "Log cleared \(Date().local)")]
                    log.labels = []
                    print("Log cleared \(Date().local)")
                } label: {
                    VStack {
                        Image(systemName: "clear")
                            .resizable()
                            .foregroundColor(.blue)
                            .frame(width: 24, height: 24)
                    }
                }
                
                Button {
                    settings.reversedLog.toggle()
                    log.entries.reverse()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(settings.reversedLog ? .blue : .clear)
                        
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(settings.reversedLog ? .clear : .blue, lineWidth: 2)
                        
                        Image(systemName: "backward.fill")
                            .resizable().frame(width: 12, height: 12)
                            .foregroundColor(settings.reversedLog ? .black : .blue)
                    }
                    .frame(width: 24, height: 24)
                }
                
                Button {
                    settings.logging.toggle()
                    app.main.log("\(settings.logging ? "Log started" : "Log stopped") \(Date().local)")
                } label: {
                    VStack {
                        Image(systemName: settings.logging ? "stop.circle" : "play.circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(settings.logging ? .red : .green)
                    }
                }
            }
            .footnote()
        }
        // FIXME: Filter toolbar item disappearing
        // .padding(.top, -4)
        .edgesIgnoringSafeArea(.bottom)
        .navigationTitle("Console")
        .accentColor(.blue)
    }
}

#Preview {
    Console()
        .environment(AppState.test(tab: .console))
        .environment(Log())
        .environment(Settings())
}
