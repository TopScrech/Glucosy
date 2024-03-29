import SwiftUI

struct ConsoleTools: View {
    @Environment(Settings.self) private var settings: Settings
    @Environment(Log.self)      private var log: Log
    @Environment(AppState.self)         var app: AppState
    
    @State private var onlineCountdown = 0
    @State private var readingCountdown = 0
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Button {
                app.main.rescan()
            } label: {
                Image(.bluetooth)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            
            if (app.status.hasPrefix("Scanning") || app.status.hasSuffix("retrying...")) && app.main.centralManager.state != .poweredOff {
                Button {
                    app.main.centralManager.stopScan()
                    app.main.status("Stopped scanning")
                    app.main.log("Bluetooth: stopped scanning")
                } label: {
                    Image(systemName: "octagon")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .overlay {
                            Image(systemName: "hand.raised.fill")
                                .resizable()
                                .frame(width: 12, height: 12)
                        }
                }
                .foregroundColor(.red)
                
            } else if deviceState == "Connected" || deviceState == "Reconnecting..." || app.status.hasSuffix("retrying...") {
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
                }
                
            } else {
                Image(systemName: "octagon")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .hidden()
            }
            
            if onlineCountdown <= 0 && !deviceState.isEmpty && deviceState != "Disconnected" {
                VStack(spacing: 0) {
                    Text(readingCountdown > 0 || deviceState == "Reconnecting..." ?
                         "\(readingCountdown)" : " ")
                    
                    Text(readingCountdown > 0 || deviceState == "Reconnecting..." ?
                         "s" : " ")
                }
                .monospacedDigit()
                .foregroundColor(.orange)
                .frame(width: 24, height: 24)
                .allowsTightening(true)
                .fixedSize()
                .onReceive(app.secondTimer) { _ in
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
                .monospacedDigit()
                .onReceive(app.secondTimer) { _ in
                    // workaround: watchOS fails converting the interval to an Int32
                    
                    if settings.lastOnlineDate == Date.distantPast {
                        onlineCountdown = 0
                    } else {
                        onlineCountdown = settings.onlineInterval * 60 - Int(Date().timeIntervalSince(settings.lastOnlineDate))
                    }
                }
            
            Spacer()
            
            Button {
                settings.userLevel = .init(rawValue:(settings.userLevel.rawValue + 1) % UserLevel.allCases.count)!
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(settings.userLevel != .basic ? .blue : .clear)
                    
                    Image(systemName: ["doc.plaintext", "ladybug", "testtube.2"][settings.userLevel.rawValue])
                        .title3()
                        .foregroundColor(settings.userLevel != .basic ? .black : .blue)
                }
                .frame(width: 24, height: 24)
            }
            
            // Button {
            //     UIPasteboard.general.string = log.entries.map(\.message).joined(separator: "\n \n")
            // } label: {
            //     VStack {
            //         Image(systemName: "doc.on.doc")
            //             .title3()
            //
            //         Text("Copy")
            //     }
            // }
            
            Button {
                log.entries = [LogEntry(message: "Log cleared \(Date().local)")]
                log.labels = []
                
                print("Log cleared \(Date().local)")
                
            } label: {
                Image(systemName: "delete.left")
                    .title3()
            }
            
            Button {
                settings.reversedLog.toggle()
                log.entries.reverse()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(settings.reversedLog ? .blue : .clear)
                    
                    Image(systemName: "backward.fill")
                        .foregroundColor(settings.reversedLog ? .black : .blue)
                }
                .frame(width: 24, height: 24)
            }
            
            Button {
                settings.logging.toggle()
                
                app.main.log("\(settings.logging ? "Log started" : "Log stopped") \(Date().local)")
            } label: {
                Image(systemName: settings.logging ? "stop" : "play")
                    .title3()
                    .foregroundColor(settings.logging ? .red : .green)
            }
        }
        .padding(.bottom)
        .footnote()
    }
}

#Preview {
    Console()
        .glucosyPreview(.console)
}
