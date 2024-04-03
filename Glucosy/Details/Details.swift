import SwiftUI

struct Details: View {
    @Environment(AppState.self) private var app: AppState
    @Environment(Settings.self) private var settings: Settings
    
    @State private var showingRePairConfirmationDialog = false
    @State private var showingCalibrationInfoForm = false
    
    @State private var readingCountdown = 0
    @State private var secondsSinceLastConnection = 0
    @State private var minutesSinceLastReading = 0
        
    private func repair() {
        ((app.device as? Abbott)?.sensor as? Libre3)?.pair()
        
        guard app.main.nfc.isAvailable else {
            app.alertNfc = true
            return
        }
        
        settings.logging = true
        settings.selectedTab = .console
        
        if app.sensor as? Libre3 == nil {
            showingRePairConfirmationDialog = true
        } else {
            app.main.nfc.taskRequest = .enableStreaming
        }
    }
    
    var body: some View {
        VStack {
            Form {
                if app.status.starts(with: "Scanning") {
                    Text("\(app.status)")
                        .footnote()
                } else {
                    if app.device == nil && app.sensor == nil {
                        Text("No device connected")
                            .foregroundColor(.red)
                    }
                }
                
                if app.device != nil {
                    Section("Device") {
                        Group {
                            ListRow("Name", app.device.peripheral?.name ?? app.device.name)
                            
                            ListRow("State", (app.device.peripheral?.state ?? app.device.state).description.capitalized,
                                foregroundColor: (app.device.peripheral?.state ?? app.device.state) == .connected ? .green : .red)
                            
                            if app.device.lastConnectionDate != .distantPast {
                                HStack {
                                    Text("Since")
                                    
                                    Spacer()
                                    
                                    Text("\(secondsSinceLastConnection.minsAndSecsFormattedInterval)")
                                        .monospacedDigit()
                                        .foregroundColor(app.device.state == .connected ? .yellow : .red)
                                        .onReceive(app.secondTimer) { _ in
                                            if let device = app.device {
                                                secondsSinceLastConnection = Int(Date().timeIntervalSince(device.lastConnectionDate))
                                            } else {
                                                secondsSinceLastConnection = 1
                                            }
                                        }
                                }
                            }
                            
                            if settings.userLevel > .basic && app.device.peripheral != nil {
                                ListRow("Identifier", app.device.peripheral!.identifier.uuidString)
                            }
                            
                            if app.device.name != app.device.peripheral?.name ?? "Unnamed" {
                                ListRow("Type", app.device.name)
                            }
                        }
                        
                        ListRow("Serial", app.device.serial)
                        
                        Group {
                            if !app.device.company.isEmpty && app.device.company != "< Unknown >" {
                                ListRow("Company", app.device.company)
                            }
                            
                            ListRow("Manufacturer", app.device.manufacturer)
                            ListRow("Model", app.device.model)
                            ListRow("Firmware", app.device.firmware)
                            ListRow("Hardware", app.device.hardware)
                            ListRow("Software", app.device.software)
                        }
                        
                        if app.device.macAddress.count > 0 {
                            ListRow("MAC Address", app.device.macAddress.hexAddress)
                        }
                        
                        if app.device.rssi != 0 {
                            ListRow("RSSI", "\(app.device.rssi) dB")
                        }
                        
                        if app.device.battery > -1 {
                            ListRow("Battery", "\(app.device.battery)%",
                                foregroundColor: app.device.battery > 10 ? .green : .red)
                        }
                    }
                    .callout()
                }
                
                if app.sensor != nil {
                    Section("Sensor") {
                        ListRow("State", app.sensor.state.description,
                            foregroundColor: app.sensor.state == .active ? .green : .red)
                        
                        if app.sensor.state == .failure && app.sensor.fram.count > 8 {
                            let fram = app.sensor.fram
                            let errorCode = fram[6]
                            let failureAge = Int(fram[7]) + Int(fram[8]) << 8
                            let failureInterval = failureAge == 0 ? "an unknown time" : "\(failureAge.formattedInterval)"
                            ListRow("Failure", "\(decodeFailure(error: errorCode).capitalized) (0x\(errorCode.hex)) at \(failureInterval)",
                                foregroundColor: .red)
                        }
                        
                        ListRow("Type", "\(app.sensor.type.description)\(app.sensor.patchInfo.hex.hasPrefix("a2") ? " (new 'A2' kind)" : "")")
                        
                        ListRow("Serial", app.sensor.serial)
                        
                        ListRow("Reader Serial", app.sensor.readerSerial.count >= 16 ? app.sensor.readerSerial[...13].string : "")
                        
                        ListRow("Region", app.sensor.region.description)
                        
                        if app.sensor.maxLife > 0 {
                            ListRow("Maximum Life", app.sensor.maxLife.formattedInterval)
                        }
                        
                        if app.sensor.age > 0 {
                            Group {
                                ListRow("Age", (app.sensor.age + minutesSinceLastReading).formattedInterval)
                                
                                if app.sensor.maxLife - app.sensor.age - minutesSinceLastReading > 0 {
                                    ListRow("Ends in", (app.sensor.maxLife - app.sensor.age - minutesSinceLastReading).formattedInterval,
                                        foregroundColor: (app.sensor.maxLife - app.sensor.age - minutesSinceLastReading) > 360 ? .green : .red)
                                }
                                
                                ListRow("Started on", (app.sensor.activationTime > 0 ? Date(timeIntervalSince1970: Double(app.sensor.activationTime)) : (app.sensor.lastReadingDate - Double(app.sensor.age) * 60)).shortDateTime)
                            }
                            .onReceive(app.minuteTimer) { _ in
                                minutesSinceLastReading = Int(Date().timeIntervalSince(app.sensor.lastReadingDate) / 60)
                            }
                        }
                        
                        ListRow("UID", app.sensor.uid.hex)
                        
                        Group {
                            if app.sensor.type == .libre3 && (app.sensor as? Libre3)?.receiverId ?? 0 != 0 {
                                ListRow("Receiver ID", (app.sensor as! Libre3).receiverId)
                            }
                            
                            if app.sensor.type == .libre3 && ((app.sensor as? Libre3)?.blePIN ?? Data()).count != 0 {
                                ListRow("BLE PIN", (app.sensor as! Libre3).blePIN.hex)
                            }
                            
                            if !app.sensor.patchInfo.isEmpty {
                                ListRow("Patch Info",          app.sensor.patchInfo.hex)
                                ListRow("Firmware",            app.sensor.firmware)
                                ListRow("Security Generation", app.sensor.securityGeneration)
                            }
                        }
                    }
                    .callout()
                }
                
                if app.device != nil && app.device.type == .transmitter(.abbott) || settings.preferredTransmitter == .abbott {
                    Section("BLE Setup") {
                        @Bindable var settings = settings
                        
                        if app.sensor?.type != .libre3 {
                            HStack {
                                Text("Patch Info")
                                
                                TextField("Patch Info", value: $settings.activeSensorInitialPatchInfo, formatter: HexDataFormatter())
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.blue)
                            }
                            
                            HStack {
                                Text("Calibration Info")
                                
                                Spacer()
                                
                                Text("[\(settings.activeSensorCalibrationInfo.i1), \(settings.activeSensorCalibrationInfo.i2), \(settings.activeSensorCalibrationInfo.i3), \(settings.activeSensorCalibrationInfo.i4), \(settings.activeSensorCalibrationInfo.i5), \(settings.activeSensorCalibrationInfo.i6)]"
                                )
                                .foregroundColor(.blue)
                            }
                            .onTapGesture {
                                showingCalibrationInfoForm.toggle()
                            }
                            .sheet(isPresented: $showingCalibrationInfoForm) {
                                Form {
                                    Section("Calibration Info") {
                                        HStack {
                                            Text("i1")
                                            
                                            TextField("i1", value: $settings.activeSensorCalibrationInfo.i1, formatter: NumberFormatter())
                                                .keyboardType(.numbersAndPunctuation)
                                                .multilineTextAlignment(.trailing)
                                                .foregroundColor(.blue)
                                        }
                                        
                                        HStack {
                                            Text("i2")
                                            
                                            TextField("i2", value: $settings.activeSensorCalibrationInfo.i2, formatter: NumberFormatter())
                                                .keyboardType(.numbersAndPunctuation)
                                                .multilineTextAlignment(.trailing)
                                                .foregroundColor(.blue)
                                        }
                                        
                                        HStack {
                                            Text("i3")
                                            
                                            TextField("i3", value: $settings.activeSensorCalibrationInfo.i3, formatter: NumberFormatter())
                                                .keyboardType(.numbersAndPunctuation)
                                                .multilineTextAlignment(.trailing)
                                                .foregroundColor(.blue)
                                        }
                                        
                                        HStack {
                                            Text("i4")
                                            
                                            TextField("i4", value: $settings.activeSensorCalibrationInfo.i4, formatter: NumberFormatter())
                                                .keyboardType(.numbersAndPunctuation)
                                                .multilineTextAlignment(.trailing)
                                                .foregroundColor(.blue)
                                        }
                                        
                                        HStack {
                                            Text("i5")
                                            
                                            TextField("i5", value: $settings.activeSensorCalibrationInfo.i5, formatter: NumberFormatter())
                                                .keyboardType(.numbersAndPunctuation)
                                                .multilineTextAlignment(.trailing)
                                                .foregroundColor(.blue)
                                        }
                                        
                                        HStack {
                                            Text("i6")
                                            
                                            TextField("i6", value: $settings.activeSensorCalibrationInfo.i6, formatter: NumberFormatter())
                                                .keyboardType(.numbersAndPunctuation)
                                                .multilineTextAlignment(.trailing)
                                                .foregroundColor(.blue)
                                        }
                                        
                                        HStack {
                                            Button("Set") {
                                                showingCalibrationInfoForm = false
                                            }
                                            .bold()
                                            .foregroundColor(.accentColor)
                                            .padding(.horizontal, 4)
                                            .padding(2)
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .stroke(Color.accentColor, lineWidth: 2)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            HStack {
                                Text("Unlock Code")
                                
                                TextField("Unlock Code", value: $settings.activeSensorStreamingUnlockCode, formatter: NumberFormatter())
                                    .keyboardType(.numbersAndPunctuation)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.blue)
                            }
                            
                            HStack {
                                Text("Unlock Count")
                                
                                TextField("Unlock Count", value: $settings.activeSensorStreamingUnlockCount, formatter: NumberFormatter())
                                    .keyboardType(.numbersAndPunctuation)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        HStack {
                            Button {
                                repair()
                            } label: {
                                Label("RePair", systemImage: "sensor.tag.radiowaves.forward.fill")
                                    .symbolEffect(.variableColor.reversing)
                            }
                            .foregroundColor(.accentColor)
                            .confirmationDialog("Pairing a Libre 2 with this device will break LibreLink and other apps' pairings and you will have to uninstall and reinstall them to get their alarms back again.", isPresented: $showingRePairConfirmationDialog, titleVisibility: .visible) {
                                Button("RePair", role: .destructive) {
                                    app.main.nfc.taskRequest = .enableStreaming
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .callout()
                }
                
                // TODO
                if (app.device != nil && app.device.type == .transmitter(.dexcom)) || settings.preferredTransmitter == .dexcom {
                    Section("BLE Setup") {
                        @Bindable var settings = settings
                        
                        HStack {
                            Text("Transmitter Serial")
                            
                            TextField("Transmitter Serial", text: $settings.activeTransmitterSerial)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(.blue)
                        }
                        
                        HStack {
                            Text("Sensor Code")
                            
                            TextField("Sensor Code", text: $settings.activeSensorCode)
                                .keyboardType(.numbersAndPunctuation)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(.blue)
                        }
                        
                        Button {
                            // TODO
                            app.main.rescan()
                        } label: {
                            VStack(spacing: 0) {
                                Image(.bluetooth)
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .padding(.horizontal, 12)
                                
                                Text("RePair")
                                    .footnote(.bold)
                                    .padding(.bottom, 4)
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.accentColor, lineWidth: 2.5)
                            }
                        }
                        .foregroundColor(.accentColor)
                        .padding(.vertical, 4)
                    }
                    .callout()
                }
                
                // Embed a specific device setup panel
                // if app.device?.type == Custom.type {
                //     CustomDetailsView(device: app.device as! Custom)
                //     .callout()
                // }
                
                Section {
                    KnownDevicesList()
                }
            }
            .foregroundColor(.secondary)
            
            HStack(alignment: .top, spacing: 40) {
                VStack(spacing: 0) {
                    Button {
                        app.main.rescan()
                    } label: {
                        Image(systemName: "arrow.clockwise.circle")
                            .title()
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
                
                Button {
                    if app.device != nil {
                        app.main.bluetoothDelegate.knownDevices[app.device.peripheral!.identifier.uuidString]!.isIgnored = true
                        
                        app.main.centralManager.cancelPeripheralConnection(app.device.peripheral!)
                    }
                } label: {
                    Image(systemName: "escape")
                        .title()
                }
            }
            .navigationTitle("Details")
            .padding(.bottom, 8)
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            if app.sensor != nil {
                minutesSinceLastReading = Int(Date().timeIntervalSince(app.sensor.lastReadingDate) / 60)
                
            } else if app.lastReadingDate != Date.distantPast {
                minutesSinceLastReading = Int(Date().timeIntervalSince(app.lastReadingDate) / 60)
            }
        }
    }
}

#Preview {
    NavigationView {
        Details()
    }
    .glucosyPreview()
}
