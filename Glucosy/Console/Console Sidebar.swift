import SwiftUI

struct ConsoleSidebar: View {
    @Environment(AppState.self) private var app: AppState
    @Environment(Log.self)      private var log: Log
    @Environment(Settings.self) private var settings: Settings
    
    @State private var onlineCountdown = 0
    @State private var readingCountdown = 0
    
    var body: some View {
        VStack {
            Spacer()
            
            Button {
                withAnimation {
                    app.showingConsoleFilterField.toggle()
                }
            } label: {
                VStack {
                    Image(systemName: app.filterText.isEmpty ? "line.horizontal.3.decrease.circle" : "line.horizontal.3.decrease.circle.fill")
                        .title3()
                    
                    Text("Filter")
                        .foregroundStyle(.gray)
                }
            }
            
            ConsoleTools()
            
            Spacer()
            
            Button {
                settings.caffeinated.toggle()
                UIApplication.shared.isIdleTimerDisabled = settings.caffeinated
            } label: {
                Image(systemName: settings.caffeinated ? "cup.and.saucer.fill" : "cup.and.saucer")
                    .tint(.latte)
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
                        .foregroundStyle(.gray)
                }
            }
            
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
            
            VStack(spacing: 8) {
                Button {
                    settings.userLevel = .init(rawValue: (settings.userLevel.rawValue + 1) % UserLevel.allCases.count)!
                } label: {
                    VStack {
                        Image(systemName: ["doc.plaintext", "ladybug", "testtube.2"][settings.userLevel.rawValue])
                            .title2()
                        
                        Text(["Basic", "Devel", "Test"][settings.userLevel.rawValue])
                            .foregroundStyle(.gray)
                    }
                }
                
                Button {
                    UIPasteboard.general.string = log.entries.map(\.message).joined(separator: "\n \n")
                } label: {
                    VStack {
                        Image(systemName: "doc.on.doc")
                            .title2()
                        
                        Text("Copy")
                            .foregroundStyle(.gray)
                    }
                }
                
                Button {
                    log.entries = [LogEntry(message: "Log cleared \(Date().local)")]
                    log.labels = []
                    print("Log cleared \(Date().local)")
                    
                } label: {
                    VStack {
                        Image(systemName: "delete.left")
                            .title2()
                        
                        Text("Clear")
                            .foregroundStyle(.gray)
                    }
                }
            }
            
            Button {
                settings.reversedLog.toggle()
                log.entries.reverse()
            } label: {
                VStack {
                    Image(systemName: "backward.fill")
                        .headline()
                    
                    Text("REV")
                        .foregroundStyle(.gray)
                }
                .padding(3)
            }
            .background(settings.reversedLog ? Color.accentColor : .clear)
            .clipShape(.rect(cornerRadius: 5))
            .foregroundColor(settings.reversedLog ? Color(.systemBackground) : .accentColor)
            
            Button {
                settings.logging.toggle()
                app.main.log("\(settings.logging ? "Log started" : "Log stopped") \(Date().local)")
            } label: {
                Image(systemName: settings.logging ? "stop.circle" : "play.circle")
                    .title()
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
