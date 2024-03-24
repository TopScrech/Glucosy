import SwiftUI

struct ConsoleSidebar: View {
    @Environment(AppState.self) private var app: AppState
    @Environment(Log.self)      private var log: Log
    @Environment(Settings.self) private var settings: Settings
    
    @State private var onlineCountdown = 0
    @State private var readingCountdown = 0
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Spacer()
            
            VStack(spacing: 0) {
                Button {
                    if app.main.nfc.isAvailable {
                        app.main.nfc.startSession()
                    } else {
                        app.showingNfcAlert = true
                    }
                } label: {
                    Image(systemName: "sensor.tag.radiowaves.forward.fill")
                        .resizable()
                        .frame(width: 26, height: 18)
                        .padding(.init(top: 10, leading: 6, bottom: 14, trailing: 0))
                }
                
                Button {
                    app.main.rescan()
                } label: {
                    VStack {
                        Image(.bluetooth)
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 32, height: 32)
                        
                        Text("Scan")
                    }
                }
            }
            .foregroundColor(.accentColor)
            
            if (app.status.hasPrefix("Scanning") || app.status.hasSuffix("retrying...")) && app.main.centralManager.state != .poweredOff {
                Button {
                    app.main.centralManager.stopScan()
                    app.main.status("Stopped scanning")
                    app.main.log("Bluetooth: stopped scanning")
                } label: {
                    Image(systemName: "octagon")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .overlay {
                            Image(systemName: "hand.raised.fill")
                                .resizable()
                                .frame(width: 18, height: 18)
                                .offset(x: 1)
                        }
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
                        .padding(5)
                        .frame(width: 32, height: 32)
                        .foregroundColor(.blue)
                }
                
            } else {
                Image(systemName: "octagon")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .hidden()
            }
            
            VStack(spacing: 6) {
                if !app.deviceState.isEmpty && app.deviceState != "Disconnected" {
                    Text(readingCountdown > 0 || app.deviceState == "Reconnecting..." ?
                         "\(readingCountdown) s" : "")
                    .fixedSize()
                    .caption()
                    .monospacedDigit()
                    .foregroundColor(.orange)
                    .onReceive(app.secondTimer) { _ in
                        readingCountdown = settings.readingInterval * 60 - Int(Date().timeIntervalSince(app.lastConnectionDate))
                    }
                } else {
                    Text("")
                        .fixedSize()
                        .caption()
                        .monospacedDigit()
                        .hidden()
                }
                
                Text(onlineCountdown > 0 ? "\(onlineCountdown) s" : "")
                    .fixedSize()
                    .foregroundColor(.cyan)
                    .caption()
                    .monospacedDigit()
                    .onReceive(app.secondTimer) { _ in
                        onlineCountdown = settings.onlineInterval * 60 - Int(Date().timeIntervalSince(settings.lastOnlineDate))
                    }
            }
            
            Spacer()
            
            Button {
                settings.userLevel = UserLevel(rawValue: (settings.userLevel.rawValue + 1) % UserLevel.allCases.count)!
            } label: {
                VStack {
                    Image(systemName: ["doc.plaintext", "ladybug", "testtube.2"][settings.userLevel.rawValue])
                        .resizable()
                        .frame(width: 24, height: 24)
                        .offset(y: 2)
                    
                    Text(["Basic", "Devel", "Test  "][settings.userLevel.rawValue])
                        .caption()
                        .offset(y: -4)
                }
            }
            .background(settings.userLevel != .basic ? Color.accentColor : .clear)
            .clipShape(.rect(cornerRadius: 5))
            .foregroundColor(settings.userLevel != .basic ? Color(.systemBackground) : .accentColor)
            .padding(.bottom, 6)
            
            VStack(spacing: 0) {
                Button {
                    UIPasteboard.general.string = log.entries.map(\.message).joined(separator: "\n \n")
                } label: {
                    VStack {
                        Image(systemName: "doc.on.doc")
                            .resizable()
                            .frame(width: 24, height: 24)
                        
                        Text("Copy")
                            .offset(y: -6)
                    }
                }
                
                Button {
                    log.entries = [LogEntry(message: "Log cleared \(Date().local)")]
                    log.labels = []
                    print("Log cleared \(Date().local)")
                    
                } label: {
                    VStack {
                        Image(systemName: "clear")
                            .resizable()
                            .frame(width: 24, height: 24)
                        
                        Text("Clear")
                            .offset(y: -6)
                    }
                }
            }
            
            Button {
                settings.reversedLog.toggle()
                log.entries.reverse()
            } label: {
                VStack {
                    Image(systemName: "backward.fill")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .offset(y: 5)
                    
                    Text(" REV ")
                        .offset(y: -2)
                }
            }
            .background(settings.reversedLog ? Color.accentColor : Color.clear)
            .border(Color.accentColor, width: 3)
            .cornerRadius(5)
            .foregroundColor(settings.reversedLog ? Color(.systemBackground) : .accentColor)
            
            Button {
                settings.logging.toggle()
                app.main.log("\(settings.logging ? "Log started" : "Log stopped") \(Date().local)")
            } label: {
                Image(systemName: settings.logging ? "stop.circle" : "play.circle")
                    .resizable()
                    .frame(width: 32, height: 32)
            }
            .foregroundColor(settings.logging ? .red : .green)
            
            Spacer()
            
        }
        .footnote()
    }
}

#Preview {
    HomeView()
        .glucosyPreview(.console)
}
