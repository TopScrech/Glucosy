import Foundation

@Observable
final class Settings {
    static let defaults: [String: Any] = [
        "preferredTransmitter": TransmitterType.none.id,
        "preferredDevicePattern": BLE.knownDevicesIds.joined(separator: " "),
        "stoppedBluetooth": false,
        
        "caffeinated": false,
        
        "selectedTab": Tab.monitor.rawValue,
        
        "readingInterval": 5,
        
        "displayingMillimoles": true,
        "targetLow": 80.0,
        "targetHigh": 170.0,
        
        "alarmSnoozeInterval": 15,
        "lastAlarmDate": Date.distantPast,
        "alarmLow": 70.0,
        "alarmHigh": 200.0,
        "mutedAudio": false,
        "disabledNotifications": false,
        
        "calendarTitle": "",
        "calendarAlarmIsOn": false,
        
        "logging": false,
        "reversedLog": true,
        "userLevel": UserLevel.basic.rawValue,
        
        "nightscoutSite": "www.gluroo.com",
        "nightscoutToken": "",
        
        "libreLinkUpEmail": "",
        "libreLinkUpPassword": "",
        "libreLinkUpPatientId": "",
        "libreLinkUpCountry": "",
        "libreLinkUpRegion": "eu",
        "libreLinkUpToken": "",
        "libreLinkUpTokenExpirationDate": Date.distantPast,
        "libreLinkUpFollowing": false,
        "libreLinkUpScrapingLogbook": false,
        
        "selectedService": OnlineService.libreLinkUp.rawValue,
        "onlineInterval": 5,
        "lastOnlineDate": Date.distantPast,
        
        "activeSensorSerial": "",
        "activeSensorAddress": Data(),
        "activeSensorInitialPatchInfo": Data(),
        "activeSensorStreamingUnlockCode": 42,
        "activeSensorStreamingUnlockCount": 0,
        "activeSensorMaxLife": 0,
        "activeSensorCalibrationInfo": try! JSONEncoder().encode(CalibrationInfo()),
        "activeSensorBlePIN": Data(),
        
        // Dexcom
        "activeTransmitterIdentifier": "",
        "activeTransmitterSerial": "",
        "activeSensorCode": "",
        
        // TODO: rename to currentSensorUid/PatchInfo
        "patchUid": Data(),
        "patchInfo": Data()
    ]
    
    var preferredTransmitter = TransmitterType(rawValue: UserDefaults.standard.string(forKey: "preferredTransmitter")!) ?? .none {
        willSet(type) {
            if type == .dexcom  {
                readingInterval = 5
            } else if type == .abbott {
                readingInterval = 1
            }
            
            if type != .none {
                preferredDevicePattern = type.id
            } else {
                preferredDevicePattern = ""
            }
        }
        
        didSet {
            UserDefaults.standard.set(preferredTransmitter.id, forKey: "preferredTransmitter")
        }
    }
    
    var preferredDevicePattern = UserDefaults.standard.string(forKey: "preferredDevicePattern")! {
        willSet(pattern) {
            if !pattern.isEmpty {
                if !preferredTransmitter.id.matches(pattern) {
                    preferredTransmitter = .none
                }
            }
        }
        
        didSet {
            UserDefaults.standard.set(preferredDevicePattern, forKey: "preferredDevicePattern")
        }
    }
    
    var stoppedBluetooth = UserDefaults.standard.bool(forKey: "stoppedBluetooth") {
        didSet {
            UserDefaults.standard.set(stoppedBluetooth, forKey: "stoppedBluetooth")
        }
    }
    
    var caffeinated = UserDefaults.standard.bool(forKey: "caffeinated") {
        didSet {
            UserDefaults.standard.set(caffeinated, forKey: "caffeinated")
        }
    }
    
    var selectedTab = Tab(rawValue: UserDefaults.standard.string(forKey: "selectedTab")!)! {
        didSet {
            UserDefaults.standard.set(selectedTab.rawValue, forKey: "selectedTab")
        }
    }
    
    var readingInterval = UserDefaults.standard.integer(forKey: "readingInterval") {
        didSet {
            UserDefaults.standard.set(readingInterval, forKey: "readingInterval")
        }
    }
    
    var displayingMillimoles = UserDefaults(suiteName: "group.dev.topscrech.Health-Point")!.bool(forKey: "displayingMillimoles") {
        didSet {
            UserDefaults(suiteName: "group.dev.topscrech.Health-Point")!.set(displayingMillimoles, forKey: "displayingMillimoles")
        }
    }
    
    var numberFormatter = NumberFormatter()
    
    var targetLow = UserDefaults.standard.double(forKey: "targetLow") {
        didSet {
            UserDefaults.standard.set(targetLow, forKey: "targetLow")
        }
    }
    
    var targetHigh = UserDefaults.standard.double(forKey: "targetHigh") {
        didSet {
            UserDefaults.standard.set(targetHigh, forKey: "targetHigh")
        }
    }
    
    var alarmSnoozeInterval = UserDefaults.standard.integer(forKey: "alarmSnoozeInterval") {
        didSet {
            UserDefaults.standard.set(alarmSnoozeInterval, forKey: "alarmSnoozeInterval")
        }
    }
    
    var lastAlarmDate = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "lastAlarmDate")) {
        didSet {
            UserDefaults.standard.set(lastAlarmDate.timeIntervalSince1970, forKey: "lastAlarmDate")
        }
    }
    
    var alarmLow = UserDefaults.standard.double(forKey: "alarmLow") {
        didSet {
            UserDefaults.standard.set(alarmLow, forKey: "alarmLow")
        }
    }
    
    var alarmHigh = UserDefaults.standard.double(forKey: "alarmHigh") {
        didSet {
            UserDefaults.standard.set(alarmHigh, forKey: "alarmHigh")
        }
    }
    
    var mutedAudio = UserDefaults.standard.bool(forKey: "mutedAudio") {
        didSet {
            UserDefaults.standard.set(mutedAudio, forKey: "mutedAudio")
        }
    }
    
    var disabledNotifications = UserDefaults.standard.bool(forKey: "disabledNotifications") {
        didSet {
            UserDefaults.standard.set(disabledNotifications, forKey: "disabledNotifications")
        }
    }
    
    var calendarTitle = UserDefaults.standard.string(forKey: "calendarTitle")! {
        didSet {
            UserDefaults.standard.set(calendarTitle, forKey: "calendarTitle")
        }
    }
    
    var calendarAlarmIsOn = UserDefaults.standard.bool(forKey: "calendarAlarmIsOn") {
        didSet {
            UserDefaults.standard.set(calendarAlarmIsOn, forKey: "calendarAlarmIsOn")
        }
    }
    
    var logging = UserDefaults.standard.bool(forKey: "logging") {
        didSet {
            UserDefaults.standard.set(logging, forKey: "logging")
        }
    }
    
    var reversedLog = UserDefaults.standard.bool(forKey: "reversedLog") {
        didSet {
            UserDefaults.standard.set(reversedLog, forKey: "reversedLog")
        }
    }
    
    var userLevel = UserLevel(rawValue: UserDefaults.standard.integer(forKey: "userLevel"))! {
        didSet {
            UserDefaults.standard.set(userLevel.rawValue, forKey: "userLevel")
        }
    }
    
    var nightscoutSite = UserDefaults.standard.string(forKey: "nightscoutSite")! {
        didSet {
            UserDefaults.standard.set(nightscoutSite, forKey: "nightscoutSite")
        }
    }
    
    var nightscoutToken = UserDefaults.standard.string(forKey: "nightscoutToken")! {
        didSet {
            UserDefaults.standard.set(nightscoutToken, forKey: "nightscoutToken")
        }
    }
    
    var libreLinkUpEmail = UserDefaults.standard.string(forKey: "libreLinkUpEmail")! {
        didSet {
            UserDefaults.standard.set(libreLinkUpEmail, forKey: "libreLinkUpEmail")
        }
    }
    
    var libreLinkUpPassword = UserDefaults.standard.string(forKey: "libreLinkUpPassword")! {
        didSet {
            UserDefaults.standard.set(libreLinkUpPassword, forKey: "libreLinkUpPassword")
        }
    }
    
    var libreLinkUpPatientId = UserDefaults.standard.string(forKey: "libreLinkUpPatientId")! {
        didSet {
            UserDefaults.standard.set(libreLinkUpPatientId, forKey: "libreLinkUpPatientId")
        }
    }
    
    var libreLinkUpCountry = UserDefaults.standard.string(forKey: "libreLinkUpCountry")! {
        didSet {
            UserDefaults.standard.set(libreLinkUpCountry, forKey: "libreLinkUpCountry")
        }
    }
    
    var libreLinkUpRegion = UserDefaults.standard.string(forKey: "libreLinkUpRegion")! {
        didSet {
            UserDefaults.standard.set(libreLinkUpRegion, forKey: "libreLinkUpRegion")
        }
    }
    
    var libreLinkUpToken = UserDefaults.standard.string(forKey: "libreLinkUpToken")! {
        didSet {
            UserDefaults.standard.set(libreLinkUpToken, forKey: "libreLinkUpToken")
        }
    }
    
    var libreLinkUpTokenExpirationDate = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "libreLinkUpTokenExpirationDate")) {
        didSet {
            UserDefaults.standard.set(libreLinkUpTokenExpirationDate.timeIntervalSince1970, forKey: "libreLinkUpTokenExpirationDate")
        }
    }
    
    var libreLinkUpFollowing = UserDefaults.standard.bool(forKey: "libreLinkUpFollowing") {
        didSet {
            UserDefaults.standard.set(libreLinkUpFollowing, forKey: "libreLinkUpFollowing")
        }
    }
    
    var libreLinkUpScrapingLogbook = UserDefaults.standard.bool(forKey: "libreLinkUpScrapingLogbook") {
        didSet {
            UserDefaults.standard.set(libreLinkUpScrapingLogbook, forKey: "libreLinkUpScrapingLogbook")
        }
    }
    
    var selectedService = OnlineService(rawValue: UserDefaults.standard.string(forKey: "selectedService")!)! {
        didSet {
            UserDefaults.standard.set(selectedService.rawValue, forKey: "selectedService")
        }
    }
    
    var onlineInterval = UserDefaults.standard.integer(forKey: "onlineInterval") {
        didSet {
            UserDefaults.standard.set(onlineInterval, forKey: "onlineInterval")
        }
    }
    
    var lastOnlineDate = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "lastOnlineDate")) {
        didSet {
            UserDefaults.standard.set(lastOnlineDate.timeIntervalSince1970, forKey: "lastOnlineDate")
        }
    }
    
    var activeSensorSerial = UserDefaults.standard.string(forKey: "activeSensorSerial")! {
        didSet {
            UserDefaults.standard.set(activeSensorSerial, forKey: "activeSensorSerial")
        }
    }
    
    var activeSensorAddress = UserDefaults.standard.data(forKey: "activeSensorAddress")! {
        didSet {
            UserDefaults.standard.set(activeSensorAddress, forKey: "activeSensorAddress")
        }
    }
    
    var activeSensorInitialPatchInfo: PatchInfo = UserDefaults.standard.data(forKey: "activeSensorInitialPatchInfo")! {
        didSet {
            UserDefaults.standard.set(activeSensorInitialPatchInfo, forKey: "activeSensorInitialPatchInfo")
        }
    }
    
    var activeSensorStreamingUnlockCode = UserDefaults.standard.integer(forKey: "activeSensorStreamingUnlockCode") {
        didSet {
            UserDefaults.standard.set(activeSensorStreamingUnlockCode, forKey: "activeSensorStreamingUnlockCode")
        }
    }
    
    var activeSensorStreamingUnlockCount = UserDefaults.standard.integer(forKey: "activeSensorStreamingUnlockCount") {
        didSet {
            UserDefaults.standard.set(activeSensorStreamingUnlockCount, forKey: "activeSensorStreamingUnlockCount")
        }
    }
    
    var activeSensorMaxLife = UserDefaults.standard.integer(forKey: "activeSensorMaxLife") {
        didSet {
            UserDefaults.standard.set(activeSensorMaxLife, forKey: "activeSensorMaxLife")
        }
    }
    
    var activeSensorCalibrationInfo = try! JSONDecoder().decode(CalibrationInfo.self, from: UserDefaults.standard.data(forKey: "activeSensorCalibrationInfo")!) {
        didSet {
            UserDefaults.standard.set(try! JSONEncoder().encode(activeSensorCalibrationInfo), forKey: "activeSensorCalibrationInfo")
        }
    }
    
    var activeSensorBlePIN = UserDefaults.standard.data(forKey: "activeSensorBlePIN")! {
        didSet {
            UserDefaults.standard.set(activeSensorBlePIN, forKey: "activeSensorBlePIN")
        }
    }
    
    var activeTransmitterIdentifier = UserDefaults.standard.string(forKey: "activeTransmitterIdentifier")! {
        didSet {
            UserDefaults.standard.set(activeTransmitterIdentifier, forKey: "activeTransmitterIdentifier")
        }
    }
    
    var activeTransmitterSerial = UserDefaults.standard.string(forKey: "activeTransmitterSerial")! {
        didSet {
            UserDefaults.standard.set(activeTransmitterSerial, forKey: "activeTransmitterSerial")
        }
    }
    
    var activeSensorCode = UserDefaults.standard.string(forKey: "activeSensorCode")! {
        didSet {
            UserDefaults.standard.set(activeSensorCode, forKey: "activeSensorCode")
        }
    }
    
    var patchUid = UserDefaults.standard.data(forKey: "patchUid")! {
        didSet {
            UserDefaults.standard.set(patchUid, forKey: "patchUid")
        }
    }
    
    var patchInfo = UserDefaults.standard.data(forKey: "patchInfo")! {
        didSet {
            UserDefaults.standard.set(patchInfo, forKey: "patchInfo")
        }
    }
}

// TODO: validate inputs

final class HexDataFormatter: Formatter {
    override func string(for obj: Any?) -> String? {
        (obj as! Data).hex
    }
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        var str = string.filter(\.isHexDigit)
        
        if str.count % 2 == 1 {
            str = "0" + str
        }
        
        obj?.pointee = str.bytes as AnyObject
        
        return true
    }
}
