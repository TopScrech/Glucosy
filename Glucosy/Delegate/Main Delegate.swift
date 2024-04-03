import SwiftUI
import WidgetKit
import CoreBluetooth
import AVFoundation
import os.log

protocol Logging {
    var main: MainDelegate! {
        get set
    }
}

extension Logging {
    func log(_ msg: String)      { main?.log(msg) }
    func debugLog(_ msg: String) { main?.debugLog(msg) }
    
    var app: AppState            { main.app }
    var settings: Settings       { main.settings }
}

class MainDelegate: UIResponder, UIApplicationDelegate, UIWindowSceneDelegate {
    var app: AppState
    var logger: Logger
    var log: Log
    var history: History
    var settings: Settings
    var storage: Storage
    
    var centralManager: CBCentralManager
    var bluetoothDelegate: BluetoothDelegate
    var nfc: NFC
    var healthKit: HealthKit?
    var libreLinkUp: LibreLinkUp?
    var nightscout: Nightscout?
    var eventKit: EventKit?
    
    override init() {
        UserDefaults.standard.register(defaults: Settings.defaults)
        
        settings = Settings()
        logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Debug")
        log = Log()
        history = History()
        app = AppState()
        storage = Storage()
        
        bluetoothDelegate = BluetoothDelegate()
        
        centralManager = CBCentralManager(
            delegate: bluetoothDelegate,
            queue: nil,
            options: [CBCentralManagerOptionRestoreIdentifierKey: "Glucosy"]
        )
        
        nfc = NFC()
        healthKit = HealthKit()
        
        super.init()
        
        let welcomeMessage = "Welcome to Glucosy!\n\nTip: switch from [Basic] to [Test] mode to sniff incoming BLE data running side-by-side with Trident and other apps.\n\nHint: better [Stop] me to avoid excessive logging during normal use.\n\nWarning: edit out your sensitive personal data after [Copy]ing and before pasting into your reports."
        
        log.entries = [
            .init(message: "\(welcomeMessage)"),
            .init(message: "\(settings.logging ? "Log started" : "Log stopped") \(Date().local)")
        ]
        
        debugLog("User defaults: \(Settings.defaults.keys.map { [$0, UserDefaults.standard.dictionaryRepresentation()[$0]!] }.sorted{($0[0] as! String) < ($1[0] as! String) })")
        
        app.main = self
        bluetoothDelegate.main = self
        nfc.main = self
        
        if let healthKit {
            healthKit.main = self
            
            healthKit.authorize { [self] in
                log("HealthKit: \( $0 ? "" : "not ")authorized")
                
                if healthKit.isAuthorized {
                    healthKit.readGlucose() { [self] in
                        debugLog("HealthKit last 12 stored values: \($0[..<(min(12, $0.count))])")
                    }
                }
            }
        } else {
            log("HealthKit: not available")
        }
        
        libreLinkUp = LibreLinkUp(main: self)
        nightscout = Nightscout(main: self)
        nightscout!.read()
        eventKit = EventKit(main: self)
        eventKit?.sync()
        
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 8
        settings.numberFormatter = numberFormatter
        
        // features currently in beta testing
        if settings.userLevel >= .test {
            Libre3.testAESCCM()
        }
    }
    
    func processDeepLink(_ url: URL) {
        switch url.description {
        case "action/nfc":
            nfc.startSession()
            
        case "action/new_record":
            app.sheetNewRecord = true
            
        default:
            print("Deeplinking")
        }
    }
    
    func log(_ msg: String, level: LogLevel = .info, label: String = "") {
        if settings.logging || msg.hasPrefix("Log") {
            let entry = LogEntry(message: msg, level: level, label: label)
            
            Task { @MainActor in
                if settings.reversedLog {
                    log.entries.insert(entry, at: 0)
                } else {
                    log.entries.append(entry)
                }
                
                print(msg)
                
                if settings.userLevel > .basic {
                    logger.log("\(msg)")
                }
                
                if !entry.label.isEmpty {
                    log.labels.insert(entry.label)
                }
            }
        }
    }
    
    func debugLog(_ msg: String) {
        if settings.userLevel > .basic {
            log(msg, level: .debug)
        }
    }
    
    func status(_ text: String) {
        Task { @MainActor in
            app.status = text
        }
    }
    
    func errorStatus(_ text: String) {
        if !app.status.contains(text) {
            Task { @MainActor in
                app.status.append("\n\(text)")
            }
        }
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let shortcutItem = connectionOptions.shortcutItem {
            if shortcutItem.type == "NFC" {
                nfc.startSession()
            }
        }
    }
    
    func rescan() {
        if let device = app.device {
            centralManager.cancelPeripheralConnection(device.peripheral!)
        }
        
        if centralManager.state == .poweredOn {
            settings.stoppedBluetooth = false
            
            if !(settings.preferredDevicePattern.matches("abbott") || settings.preferredDevicePattern.matches("dexcom")) {
                log("Bluetooth: scanning...")
                status("Scanning...")
                centralManager.scanForPeripherals(withServices: nil, options: nil)
                
            } else {
                if let peripheral = centralManager.retrieveConnectedPeripherals(withServices: [CBUUID(string: Libre3.UUID.data.rawValue)]).first {
                    log("Bluetooth: retrieved \(peripheral.name ?? "unnamed peripheral")")
                    
                    bluetoothDelegate.centralManager(
                        centralManager,
                        didDiscover: peripheral,
                        advertisementData: [CBAdvertisementDataServiceUUIDsKey: [CBUUID(string: Libre3.UUID.data.rawValue)]],
                        rssi: 0
                    )
                    
                } else if let peripheral = centralManager.retrieveConnectedPeripherals(withServices: [CBUUID(string: Abbott.dataServiceUUID)]).first {
                    log("Bluetooth: retrieved \(peripheral.name ?? "unnamed peripheral")")
                    
                    bluetoothDelegate.centralManager(
                        centralManager,
                        didDiscover: peripheral,
                        advertisementData: [CBAdvertisementDataServiceUUIDsKey: [CBUUID(string: Abbott.dataServiceUUID)]],
                        rssi: 0
                    )
                    
                } else if let peripheral = centralManager.retrieveConnectedPeripherals(withServices: [CBUUID(string: Dexcom.UUID.advertisement.rawValue)]).first {
                    log("Bluetooth: retrieved \(peripheral.name ?? "unnamed peripheral")")
                    
                    bluetoothDelegate.centralManager(
                        centralManager,
                        didDiscover: peripheral,
                        advertisementData: [CBAdvertisementDataServiceUUIDsKey: [CBUUID(string: Dexcom.UUID.advertisement.rawValue)]],
                        rssi: 0
                    )
                    
                } else {
                    log("Bluetooth: scanning for a Libre/Dexcom...")
                    status("Scanning for a Libre/Dexcom...")
                    
                    centralManager.scanForPeripherals(withServices: nil, options: nil)
                }
            }
        } else {
            log("Bluetooth is powered off: cannot scan")
        }
        
        healthKit?.readGlucose()
        nightscout?.read()
    }
    
    func playAlarm() {
        let currentGlucose = app.currentGlucose
        
        if !settings.mutedAudio {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, options: [.duckOthers])
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                log("Audio Session error: \(error)")
            }
            
            let soundName = currentGlucose > Int(settings.alarmHigh) ? "alarm_high" : "alarm_low"
            
            let audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: soundName, ofType: "mp3")!), fileTypeHint: "mp3")
            
            audioPlayer.play()
            
            _ = Timer.scheduledTimer(withTimeInterval: 4, repeats: false) {
                _ in audioPlayer.stop()
                do {
                    try AVAudioSession.sharedInstance().setActive(false)
                } catch {
                    
                }
            }
        }
        
        if !settings.disabledNotifications {
            let times = currentGlucose > Int(settings.alarmHigh) ? 3 : 4
            let pause = times == 3 ? 1 : 5.0 / 6
            
            for s in 0..<times {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(s) * pause) {
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                }
            }
        }
    }
    
    func parseSensorData(_ sensor: Sensor) {
        sensor.detailFRAM()
        
        if sensor.history.count > 0 || sensor.trend.count > 0 {
            let calibrationInfo = sensor.calibrationInfo
            
            if sensor.serial == settings.activeSensorSerial {
                settings.activeSensorCalibrationInfo = calibrationInfo
            }
            
            history.rawTrend = sensor.trend
            log("Raw trend: \(sensor.trend.map(\.rawValue))")
            debugLog("Raw trend temperatures: \(sensor.trend.map(\.rawTemperature))")
            
            let factoryTrend = sensor.factoryTrend
            history.factoryTrend = factoryTrend
            log("Factory trend: \(factoryTrend.map(\.value))")
            
            let trendTemperatures = factoryTrend.map {
                Double(String(format: "%.1f", $0.temperature))!
            }
            
            log("Trend temperatures: \(trendTemperatures))")
            
            history.rawValues = sensor.history
            log("Raw history: \(sensor.history.map(\.rawValue))")
            
            debugLog("Raw historic temperatures: \(sensor.history.map(\.rawTemperature))")
            
            let factoryHistory = sensor.factoryHistory
            history.factoryValues = factoryHistory
            log("Factory history: \(factoryHistory.map(\.value))")
            
            let historicTemperatures = factoryHistory.map {
                Double(String(format: "%.1f", $0.temperature))!
            }
            
            log("Historic temperatures: \(historicTemperatures)")
            
            let temperatureAdjustments = factoryHistory.map {
                Double(String(format: "%.1f", $0.temperatureAdjustment))!
            }
            
            log("Temperatures adjustments: \(temperatureAdjustments)")
            
            // TODO
            debugLog("Trend has errors: \(sensor.trend.map(\.hasError))")
            
            let trendDataQuality = sensor.trend.map(\.dataQuality.description).joined(separator: ",\n")
            debugLog("Trend data quality: [\n\(trendDataQuality)\n]")
            
            let trendQualityFlags = sensor.trend.map {
                "0" + String($0.dataQualityFlags, radix: 2).suffix(2)
            }.joined(separator: ", ")
            
            debugLog("Trend quality flags: [\(trendQualityFlags)]")
            
            debugLog("History has errors: \(sensor.history.map(\.hasError))")
            
            let historyDataQuality = sensor.history.map(\.dataQuality.description).joined(separator: ",\n")
            debugLog("History data quality: [\n\(historyDataQuality)\n]")
            
            let historyQualityFlags = sensor.history.map {
                "0" + String($0.dataQualityFlags, radix: 2).suffix(2)
            }.joined(separator: ", ")
            
            debugLog("History quality flags: [\(historyQualityFlags)]")
        }
        
        debugLog("Sensor uid: \(sensor.uid.hex), saved uid: \(settings.patchUid.hex), patch info: \(sensor.patchInfo.hex.count > 0 ? sensor.patchInfo.hex : "<nil>"), saved patch info: \(settings.patchInfo.hex)")
        
        if sensor.uid.count > 0 && sensor.patchInfo.count > 0 {
            settings.patchUid = sensor.uid
            settings.patchInfo = sensor.patchInfo
        }
        
        if sensor.uid.count == 0 || settings.patchUid.count > 0 {
            if sensor.uid.count == 0 {
                sensor.uid = settings.patchUid
            }
            
            if sensor.uid == settings.patchUid {
                sensor.patchInfo = settings.patchInfo
            }
        }
        
        Task {
            didParseSensor(sensor)
        }
    }
    
    func didParseSensor(_ sensor: Sensor?) {
        guard let sensor else {
            return
        }
        
        guard sensor.state != .expired else {
            NotificationManager.shared.scheduleAlarmReminder("\(sensor.type) has expired")
            return
        }
        
        guard sensor.state != .notActivated else {
            NotificationManager.shared.scheduleAlarmReminder("\(sensor.type) is not activated")
            return
        }
        
        guard sensor.state != .warmingUp, sensor.age > 0 else {
            NotificationManager.shared.scheduleAlarmReminder("\(sensor.type) is warming up")
            return
        }
        
        if history.factoryTrend.count > 0 {
            let currentGlucose = history.factoryTrend[0].value
            app.currentGlucose = currentGlucose
            
            let userDefaults = UserDefaults(suiteName: "group.dev.topscrech.Health-Point")!
            
            userDefaults.setValue(currentGlucose.units, forKey: "currentGlucose")
            userDefaults.setValue(Date().timeIntervalSinceReferenceDate, forKey: "widgetDate")
            
            WidgetCenter.shared.reloadAllTimelines()
            
            // print("GOVNO: \(history.rawTrend[0])") // TODO: LibreLink adds 1 to the value
            // print("GOVNO: \(history.rawValues[0])")
            // print("GOVNO: \(history.factoryTrend[0])")
            // print("GOVNO: \(history.factoryValues[0])")
        }
        
        let currentGlucose = app.currentGlucose
        
        // TODO: delete mirrored implementation from Abbott Device
        // TODO: compute accurate delta and update trend arrow
        
        if history.factoryTrend.count > 6 {
            let deltaMinutes = history.factoryTrend[5].value > 0 ? 5 : 6
            
            let delta = (history.factoryTrend[0].value > 0 ? history.factoryTrend[0].value : (history.factoryTrend[1].value > 0 ? history.factoryTrend[1].value : history.factoryTrend[2].value)) - history.factoryTrend[deltaMinutes].value
            
            app.trendDeltaMinutes = deltaMinutes
            app.trendDelta = delta
        }
        
        let snoozed = settings.lastAlarmDate.timeIntervalSinceNow >= -Double(settings.alarmSnoozeInterval * 60) && settings.disabledNotifications
        
        if currentGlucose > 0 && (currentGlucose > Int(settings.alarmHigh) || currentGlucose < Int(settings.alarmLow)) {
            
            log("ALARM: current glucose: \(currentGlucose.units) (settings: high: \(settings.alarmHigh.units), low: \(settings.alarmLow.units), muted audio: \(settings.mutedAudio ? "yes" : "no")), \(snoozed ? "" : "not ")snoozed")
            
            if !snoozed {
                playAlarm()
                
                // TODO: notifications settings
                if (settings.calendarTitle == "" || !settings.calendarAlarmIsOn) && !settings.disabledNotifications {
                    
                    let glucose = currentGlucose > 0 ? currentGlucose.units : "---"
                    
                    let unit = settings.displayingMillimoles ? GlucoseUnit.mmoll.rawValue : GlucoseUnit.mgdl.rawValue
                    
                    var titleAlarm = ""
                    let alarm = app.glycemicAlarm
                    
                    if alarm != .unknown {
                        titleAlarm = alarm.shortDescription
                    } else {
                        if currentGlucose > Int(settings.alarmHigh) {
                            titleAlarm = "HIGH"
                        }
                        
                        if currentGlucose < Int(settings.alarmLow) {
                            titleAlarm = "LOW"
                        }
                    }
                    
                    let trendArrow = app.trendArrow
                    let trend = trendArrow != .unknown ? trendArrow.symbol : ""
                    
                    let title = "\(glucose) \(unit) \(titleAlarm) \(trend)"
                    
                    NotificationManager.shared.scheduleAlarmReminder(title)
                }
            }
        }
        
        if !settings.disabledNotifications {
            UNUserNotificationCenter.current().setBadgeCount(
                settings.displayingMillimoles ? Int(Float(currentGlucose.units)! * 10) : Int(currentGlucose.units)!
            )
        } else {
            UNUserNotificationCenter.current().setBadgeCount(0)
        }
        
        eventKit?.sync()
        
        if !snoozed {
            settings.lastAlarmDate = Date.now
        }
        
        saveNewData(sensor, currentGlucose: currentGlucose)
    }
}
