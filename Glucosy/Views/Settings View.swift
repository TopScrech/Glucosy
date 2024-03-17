import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var app: AppState
    @Environment(Settings.self) private var settings: Settings
    
    @State private var showingCalendarPicker = false
    
    var body: some View {
        @Bindable var settings = settings
        
        VStack {
            List {
                Section {
                    Toggle(isOn: $settings.caffeinated) {
                        Label("Karamel ice latte",
                              systemImage: settings.caffeinated ? "cup.and.saucer.fill" : "cup.and.saucer")
                        
                    }
                } footer: {
                    Text("Keep the screen on when the app is running")
                }
                
                Picker("Glucose unit", selection: $settings.displayingMillimoles) {
                    ForEach(GlucoseUnit.allCases) { unit in
                        Text(unit.description)
                            .tag(unit == .mmoll)
                    }
                }
                .pickerStyle(.inline)
                
                let range = settings.preferredTransmitter == .abbott || (settings.preferredTransmitter == .none && app.transmitter != nil && app.transmitter.type == .transmitter(.abbott)) ?
                1...1:
                settings.preferredTransmitter == .dexcom || (settings.preferredTransmitter == .none && app.transmitter != nil && app.transmitter.type == .transmitter(.dexcom)) ?
                5...5: 1...15
                
                Stepper(value: $settings.readingInterval, in: range, step: 1) {
                    HStack {
                        Image(systemName: "timer")
                            .resizable()
                            .frame(width: 24, height: 24)
                        
                        Text("\(settings.readingInterval) min")
                    }
                }
                .foregroundColor(.orange)
                
                Stepper {
                    HStack {
                        Image(systemName: settings.onlineInterval > 0 ? "network" : "wifi.slash")
                            .resizable()
                            .frame(width: 24, height: 24)
                        
                        Text(settings.onlineInterval > 0 ? "\(settings.onlineInterval) min" : "offline")
                    }
                } onIncrement: {
                    settings.onlineInterval += settings.onlineInterval >= 5 ? 5 : 1
                } onDecrement: {
                    settings.onlineInterval -= settings.onlineInterval == 0 ? 0 : settings.onlineInterval <= 5 ? 1 : 5
                }
                .foregroundColor(.cyan)
                
                Section {
                    Button("Rescan") {
                        settings.selectedTab = (settings.preferredTransmitter != .none) ? .monitor : .console
                        app.main.rescan()
                    }
                    
                    NavigationLink("Details") {
                        Details()
                    }
                }
                
                HStack(spacing: 5) {
                    Text("Target zone:")
                    
                    Text("\(settings.targetLow.units) - \(settings.targetHigh.units)")
                        .foregroundColor(.green)
                }
                
                Group {
                    Slider(value: $settings.targetLow, in: 40...99, step: 1) {
                        Text("Min")
                    }
                    
                    Slider(value: $settings.targetHigh, in: 120...300, step: 1) {
                        Text("Max")
                    }
                }
                .accentColor(.green)
                
                HStack {
                    Text("Alert when:")
                    
                    Text("< \(settings.alarmLow.units)  or  > \(settings.alarmHigh.units)")
                        .foregroundColor(.red)
                }
                
                Group {
                    Slider(value: $settings.alarmLow, in: 40...99, step: 1) {
                        Text("Min")
                    }
                    
                    Slider(value: $settings.alarmHigh, in: 120...300, step: 1) {
                        Text("Max")
                    }
                }
                .accentColor(.red)
            }
            
            Spacer()
            
            VStack(spacing: 20) {
                VStack {
                    HStack(spacing: 0) {
                        Button {
                            settings.stoppedBluetooth.toggle()
                            
                            if settings.stoppedBluetooth {
                                app.main.centralManager.stopScan()
                                app.main.status("Stopped scanning")
                                app.main.log("Bluetooth: stopped scanning")
                            } else {
                                app.main.rescan()
                            }
                        } label: {
                            Image(.bluetooth)
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.blue)
                                .overlay(settings.stoppedBluetooth ? Image(systemName: "line.diagonal")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .rotationEffect(.degrees(90)) : nil
                                )
                                .foregroundColor(.red)
                        }
                        
                        Picker("Preferred", selection: $settings.preferredTransmitter) {
                            ForEach(TransmitterType.allCases) { t in
                                Text(t.name)
                                    .tag(t)
                            }
                        }
                        .pickerStyle(.segmented)
                        .disabled(settings.stoppedBluetooth)
                    }
                    
                    HStack(spacing: 0) {
                        Button {
                            
                        } label: {
                            Image(systemName: "line.horizontal.3.decrease.circle")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(.leading, 6)
                        }
                        
                        TextField("device name pattern", text: $settings.preferredDevicePattern)
                            .padding(.horizontal, 12)
                            .frame(alignment: .center)
                    }
                }
                .foregroundColor(.accentColor)
#if targetEnvironment(macCatalyst)
                .padding(.horizontal, 15)
#endif
            }
            
            Spacer()
            
            HStack(spacing: 24) {
                Button {
                    settings.mutedAudio.toggle()
                } label: {
                    Image(systemName: settings.mutedAudio ? "speaker.slash.fill" : "speaker.2.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.accentColor)
                }
                
                HStack(spacing: 0) {
                    Button {
                        withAnimation {
                            settings.disabledNotifications.toggle()
                        }
                        
                        if settings.disabledNotifications {
                            UNUserNotificationCenter.current().setBadgeCount(0)
                        } else {
                            UNUserNotificationCenter.current().setBadgeCount(
                                settings.displayingMillimoles ? Int(Float(app.currentGlucose.units)! * 10) : Int(app.currentGlucose.units)!
                            )
                        }
                    } label: {
                        Image(systemName: settings.disabledNotifications ? "zzz" : "app.badge.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.accentColor)
                    }
                    
                    if settings.disabledNotifications {
                        Picker("", selection: $settings.alarmSnoozeInterval) {
                            ForEach([5, 15, 30, 60, 120], id: \.self) { t in
                                Text("\([5: "5 min", 15: "15 min", 30: "30 min", 60: "1 h", 120: "2 h"][t]!)")
                            }
                        }
                        .labelsHidden()
                    }
                }
                
                Button {
                    showingCalendarPicker = true
                } label: {
                    Image(systemName: settings.calendarTitle != "" ? "calendar.circle.fill" : "calendar.circle")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.accentColor)
                }
                .popover(isPresented: $showingCalendarPicker, arrowEdge: .bottom) {
                    VStack {
                        Section {
                            Button {
                                settings.calendarTitle = ""
                                showingCalendarPicker = false
                                app.main.eventKit?.sync()
                            } label: {
                                Text("None")
                                    .bold()
                                    .padding(.horizontal, 4)
                                    .padding(2)
                                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.accentColor, lineWidth: 2))
                            }
                            .disabled(settings.calendarTitle == "")
                        }
                        
                        Section {
                            Picker("Calendar", selection: $settings.calendarTitle) {
                                ForEach([""] + (app.main.eventKit?.calendarTitles ?? [""]), id: \.self) { title in
                                    Text(title != "" ? title : "None")
                                }
                            }
                            .pickerStyle(.wheel)
                        }
                        
                        Section {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.red)
                                    .padding(8)
                                
                                Toggle("High / Low", isOn: $settings.calendarAlarmIsOn)
                                    .disabled(settings.calendarTitle == "")
                            }
                        }
                        
                        Section {
                            Button {
                                showingCalendarPicker = false
                                app.main.eventKit?.sync()
                            } label: {
                                Text(settings.calendarTitle == "" ? "Don't remind" : "Remind")
                                    .bold()
                                    .padding(.horizontal, 4)
                                    .padding(2)
                                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.accentColor, lineWidth: 2))
                                    .animation(.default, value: settings.calendarTitle)
                            }
                        }
                        .padding(.top, 40)
                    }
                    .padding(60)
                }
            }
            .padding(.top, 16)
            
            Spacer()
        }
        .monospacedDigit()
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Settings")
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
        .environment(AppState.test(tab: .settings))
        .environment(Log())
        .environment(History.test)
        .environment(Settings())
}
