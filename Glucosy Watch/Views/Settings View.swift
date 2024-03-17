import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var app: AppState
    @Environment(Settings.self) private var settings: Settings
    
    @State private var showingCalendarPicker = false
    
    var body: some View {
        @Bindable var settings = settings
        
        List {
            //            Picker("Unit", selection: $settings.displayingMillimoles) {
            //                ForEach(GlucoseUnit.allCases) { unit in
            //                    Text(unit.description)
            //                        .tag(unit == .mmoll)
            //                }
            //            }
            //            .pickerStyle(.navigationLink)
            //
            //            VStack {
            //                HStack(spacing: 20) {
            //                    Text("Target range")
            //
            //                    Spacer()
            //
            //                    Text("\(settings.targetLow.units) - \(settings.targetHigh.units)")
            //                }
            //                .foregroundColor(.green)
            //
            //                Slider(value: $settings.targetLow, in: 40...99, step: 1) {
            //                    Text("Min")
            //                }
            //
            //                Slider(value: $settings.targetHigh, in: 120...300, step: 1) {
            //                    Text("Max")
            //                }
            //            }
            //            .tint(.green)
            //            .padding(.vertical)
            //
            //            VStack {
            //                HStack {
            //                    Text("Alert when")
            //
            //                    Spacer()
            //
            //                    VStack {
            //                        Text("< \(settings.alarmLow.units)")
            //                        Text("> \(settings.alarmHigh.units)")
            //                    }
            //                }
            //                .foregroundColor(.red)
            //
            //                Slider(value: $settings.alarmLow, in: 40...99, step: 1)
            //
            //                Slider(value: $settings.alarmHigh, in: 120...300, step: 1)
            //            }
            //            .tint(.red)
            //            .padding(.vertical)
            //
            //            Section {
            //                Button {
            //                    settings.stoppedBluetooth.toggle()
            //
            //                    if settings.stoppedBluetooth {
            //                        app.main.centralManager.stopScan()
            //                        app.main.status("Stopped scanning")
            //                        app.main.log("Bluetooth: stopped scanning")
            //                    } else {
            //                        app.main.rescan()
            //                    }
            //                } label: {
            //                    HStack {
            //                        Image(.bluetooth)
            //                            .renderingMode(.template)
            //                            .resizable()
            //                            .frame(width: 28, height: 28)
            //                            .foregroundColor(.blue)
            //                            .overlay(
            //                                settings.stoppedBluetooth ? Image(systemName: "line.diagonal")
            //                                    .resizable()
            //                                    .frame(width: 18, height: 18)
            //                                    .foregroundColor(.red)
            //                                    .rotationEffect(.degrees(90)) : nil
            //                            )
            //
            //                        Text("Bluetooth")
            //                    }
            //                }
            //
            //                Picker("Preferred", selection: $settings.preferredTransmitter) {
            //                    ForEach(TransmitterType.allCases) { t in
            //                        Text(t.name)
            //                            .tag(t)
            //                    }
            //                }
            //                .labelsHidden()
            //                .disabled(settings.stoppedBluetooth)
            //
            //                TextField("device name pattern", text: $settings.preferredDevicePattern)
            //                    .disabled(settings.stoppedBluetooth)
            //            }
            
            HStack {
                //                NavigationLink(destination: Monitor()) {
                Image(systemName: "timer")
                    .title2()
                //                }
                //                .simultaneousGesture(TapGesture().onEnded {
                //                    // settings.selectedTab = (settings.preferredTransmitter != .none) ? .monitor : .log
                //                    app.main.rescan()
                //                })
                
                Picker("", selection: $settings.readingInterval) {
                    let through = settings.preferredTransmitter == .abbott || (settings.preferredTransmitter == .none && app.transmitter != nil && app.transmitter.type == .transmitter(.abbott)) ? 1 :
                    settings.preferredTransmitter == .dexcom || (settings.preferredTransmitter == .none && app.transmitter != nil && app.transmitter.type == .transmitter(.dexcom)) ? 5
                    : 15
                    
                    let array = Array(stride(from: 1, through: through, by: 1))
                    
                    ForEach(array, id: \.self) { t in
                        Text("\(t) min")
                    }
                }
            }
            .foregroundColor(.orange)
            
            //            Button {
            //                settings.onlineInterval = settings.onlineInterval != 0 ? 0 : 5
            //            } label: {
            //                Image(systemName: settings.onlineInterval != 0 ? "network" : "wifi.slash")
            //                    .title2()
            //                    .foregroundColor(.cyan)
            //            }
            
            HStack {
                Image(systemName: settings.onlineInterval != 0 ? "network" : "wifi.slash")
                    .title2()
                    .foregroundColor(.cyan)
                
                Picker("", selection: $settings.onlineInterval) {
                    let interval = [0, 1, 2, 3, 4, 5, 10, 15, 20, 30, 45, 60]
                    
                    ForEach(interval, id: \.self) { t in
                        Text(t != 0 ? "\(t) min" : "offline")
                    }
                }
                .foregroundColor(.cyan)
            }
            
            Button {
                settings.mutedAudio.toggle()
            } label: {
                Image(systemName: settings.mutedAudio ? "speaker.slash.fill" : "speaker.2.fill")
                    .foregroundColor(.blue)
            }
            
            Button {
                withAnimation {
                    settings.disabledNotifications.toggle()
                }
            } label: {
                Image(systemName: settings.disabledNotifications ? "zzz" : "app.badge.fill")
                    .foregroundColor(.blue)
            }
            
            if settings.disabledNotifications {
                Picker("", selection: $settings.alarmSnoozeInterval) {
                    let interval = [5, 15, 30, 60, 120]
                    
                    ForEach(interval, id: \.self) { t in
                        Text("\([5: "5m", 15: "15 m", 30: "30m", 60: "1h", 120: "2h"][t]!)")
                    }
                }
                .foregroundColor(.blue)
            }
        }
        .monospacedDigit()
        .navigationTitle("Settings")
        .tint(.blue)
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
    .glucosyPreview(.settings)
}
