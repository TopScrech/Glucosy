import Foundation
import RealmSwift

class AlarmConfigEntity: Object {
    @objc dynamic var _alarmType = 0
    @objc dynamic var _id = 0
    @objc dynamic var _enabled = false
    @objc dynamic var _threshold = 0.0
    @objc dynamic var _soundType = 0
    @objc dynamic var _soundSetting = ""
    @objc dynamic var _tolerance = 0.0
    @objc dynamic var _f_high = 0.0
    @objc dynamic var _overrideDND = false
    
    override static func primaryKey() -> String? {
        "_alarmType"
    }
}

class AppConfigEntity: Object {
    @objc dynamic var _configName = ""
    @objc dynamic var _id = 0
    @objc dynamic var _configType = 0
    @objc dynamic var _configValue = ""
    @objc dynamic var _source = 0                // ConfigSource 1: build, 2: runtime
    
    override static func primaryKey() -> String? {
        "_configName"
    }
    
    // TODO
    
    /// [_configName]
    static let keys = [
        ["_libreviewAccountIdKey_"],
        ["_libreviewDateOfBirthKey_"],
        ["_libreviewDidAcceptCRMAgreement_"],
        ["_libreviewEmailKey_"],
        ["_libreviewFirstNameKey_"],
        ["_libreviewLastNameKey_"],
        ["_libreviewMinorRuleKey_"],
        ["_libreviewTransitionableSensorSerialNumberKey_"],
        ["_libreviewUserNameKey_"],
        ["_libreviewUserTokenKey_"],
        ["_NEWYU_STATUS_20_TIMESTAMP_KEY_"],
        ["_pending_sensor_upload_"],
        ["acceptedHIPAAAuthLanguage"],
        ["acceptedPhoneWarningsLanguage"],
        ["acceptedPhoneWarningsVersion"],
        ["acceptedPrivacyNoticeLanguage"],
        ["acceptedPrivacyNoticeVersion"],
        ["acceptedTermsOfUseLanguage"],
        ["acceptedTermsOfUseVersion"],
        ["AMSensorWarmupCompleteEvent"],
        ["appAssets"],
        ["appDefaultServingSize"],
        ["appEnvironmentKey"],
        ["appMinimumAge"],
        ["appProductStandardNumber"],
        ["appRegistrationNumber"],
        ["appVersionAssetDownloadedKey"],
        ["appVersionStringWhenSetKey"],
        ["AUBannerNotificationsEnabled"],
        ["AUBluetoothIsEnabled"],
        ["AUCriticalAlertEnabled"],
        ["AUFixedLowGlucoseIsEnabled"],
        ["AUFixedLowGlucoseOverrideDND"],
        ["AUHighGlucoseIsEnabled"],
        ["AUHighGlucoseOverrideDND"],
        ["AULockScreenNotificationsEnabled"],
        ["AULowGlucoseIsEnabled"],
        ["AULowGlucoseOverrideDND"],
        ["AUNotificationsAreEnabled"],
        ["AUNotificationSoundsEnabled"],
        ["AUOSCompatibilityStatus"],
        ["AUSignalLossGlucoseIsEnabled"],
        ["AUSignalLossGlucoseOverrideDND"],
        ["AUSignalLossStatus"],
        ["deviceAddress"],
        ["didAcceptHIPAAAuth"],
        ["didAcceptPhoneWarnings"],
        ["didAcceptPrivacyNotice"],
        ["didAcceptTermsOfUse"],
        ["didAllowCriticalAlertsPermission"],
        ["didSeeAlarmsAudioExplanation"],
        ["didSeeAlarmsTutorial2"],
        ["didSeeAlarmsTutorial4"],
        ["didSeeAlarmsTutorial5"],
        ["didSeeCarbohydrateUnits"],
        ["didSeeContinousGlucoseReadings"],
        ["didSeeCriticalAlertsPermission"],
        ["didSeeGlucoseBackgroundColorExplanation"],
        ["didSeeResultsScreenExplanation"],
        ["didSeeTargetGlucoseRange"],
        ["didSeeTrendArrowsExplanation"],
        ["didSeeTutorialWelcomeScreen"],
        ["didSeeUnitsOfMeasure"],
        ["didSeeVitaminCWarningScreen"],
        ["didTreatmentDecisions1Explanation"],
        ["didTreatmentDecisions2Explanation"],
        ["firstConnect"],
        ["firstTimeAlarmsAccess"],
        ["firstTimeTurnOnGlucoseAlarm"],
        ["highGlucoseAlarmTone"],
        ["highGlucoseAlarmValue"],
        ["hipaa_status"],
        ["installationId"],
        ["isHighGlucoseAlarmOn"],
        ["isLowGlucoseAlarmOn"],
        ["isSignalLossAlarmOn"],
        ["isTextToSpeechOn"],
        ["kUnavailable_Alarm_Can_Be_Presented"],
        ["LAST_SL_LOG_UPDATE_TIMESTAMP"],
        ["lastEventReceived"],
        ["lastUpdateCheckTimestamp"],
        ["lastUpdateCheckTimestampPhoneWarnings"],
        ["latestPhoneWarningsVersion"],
        ["latestPrivacyNoticeVersion"],
        ["latestTermsOfUseVersion"],
        ["Libre3WrappedKAuth"],                      // 149 bytes hex
        ["lowGlucoseAlarmTone"],
        ["lowGlucoseAlarmValue"],
        ["newYuApiKey"],
        ["newYuDomain"],
        ["newYuGateway"],
        ["newYuShareUrl"],
        ["newYuUrl"],
        ["oneStepAudience"],
        ["oneStepBaseUrl"],
        ["oneStepIssuer"],
        ["oneStepSubject"],
        ["rwe_status"],
        ["sandboxUrl"],
        ["signalLossAlarmTone"],
        ["SignalLossDateTime_"],
        ["SignalLossDateTime_1"],
        ["SignalLossDateTime_2"],
        ["SignalLossDateTime_3"],
        ["SignalLossDateTime_4"],
        ["SignalLossDateTime_5"],
        ["SignalLossDateTime_6"],
        ["SignalLossEndDateTime"],
        ["SignalLossScheduleCount"],
        ["SignalLossUserDismissTime"],
        ["startSensorVideoUrl"],
        ["userAccountMode"],                         // UserAccountType string
        ["userCarbUnit"],
        ["userGlucoseUnit"],
        ["userGramsPerServing"],
        ["userMaxGlucoseRange"],
        ["userMinGlucoseRange"]
    ]
}

class AppEventEntity: Object {
    @objc dynamic var _id = 0
    @objc dynamic var _eventType = 0
    @objc dynamic var _eventErrorCode = 0       // DPCRLInterface
    @objc dynamic var _timestampUTC = 0
    @objc dynamic var _timestampLocal = 0
    @objc dynamic var _timeZone = ""
    @objc dynamic var _eventParams = ""
    @objc dynamic var _eventData = ""
    @objc dynamic var _display = false
    
    override static func primaryKey() -> String? {
        "_id"
    }
    
    override static func indexedProperties() -> [String] {
        ["_eventType", "_eventErrorCode", "_timestampUTC", "_timeZone"]
    }
}

class GlucoseReadingEntity: Object {
    @objc dynamic var _compositeKey = 0         // _sensor._id << 32 + _lifeCount
    @objc dynamic var _id = 0
    @objc dynamic var _sensor: SensorEntity?
    @objc dynamic var _lifeCount = 0
    @objc dynamic var _timestampUTC = 0
    @objc dynamic var _timestampLocal = 0
    @objc dynamic var _timeZone = ""
    @objc dynamic var _currentGlucose = 0.0
    @objc dynamic var _uncappedGlucose = 0.0
    @objc dynamic var _historicGlucose = 0.0
    @objc dynamic var _trend = 0
    @objc dynamic var _rateOfChange = 0.0
    @objc dynamic var _dqFlag = 0
    @objc dynamic var _historicDqFlag = 0
    @objc dynamic var _actionable = 0
    @objc dynamic var _sensorCondition = 0
    @objc dynamic var _esaDuration = 0
    @objc dynamic var _alarmPresentFlag = 0
    @objc dynamic var _alarmRemoveFlag = 0
    @objc dynamic var _alarmEpisodeFlag = 0
    @objc dynamic var _glycemicAlarmStatus = 0
    @objc dynamic var _projectedGlucose = 0.0
    @objc dynamic var _resultRange = 0
    let _notes = List<NotesEntity>()
    @objc dynamic var _temperature = 0
    @objc dynamic var _rawData = ""          // 8 bytes hex
    @objc dynamic var _viewed = false
    @objc dynamic var _extendedUDOflag = 0
    @objc dynamic var _rssi = 0
    @objc dynamic var _isWarmup = false
    @objc dynamic var _uncappedHistoric = 0.0
    @objc dynamic var _userResultRange = 0
    let _stateMap = List<Int>()
    @objc dynamic var _isHistoric = false
    
    override static func primaryKey() -> String? {
        "_compositeKey"
    }
    
    override static func indexedProperties() -> [String] {
        ["_id", "_lifeCount", "_timestampUTC", "_timestampLocal"]
    }
}

class NoteElementEntity: Object {
    @objc dynamic var _id = 0
    @objc dynamic var _noteType = 0
    @objc dynamic var _subType = 0
    @objc dynamic var _value = 0.0
    @objc dynamic var _servingSize = 0.0
    
    override static func primaryKey() -> String? {
        "_id"
    }
}

class NotesEntity: Object {
    @objc dynamic var _id = 0
    @objc dynamic var _timestampUTC = 0
    @objc dynamic var _timestampLocal = 0
    @objc dynamic var _timeZone = ""
    @objc dynamic var _comment: String? = nil
    @objc dynamic var _glucoseReading: GlucoseReadingEntity?
    let _noteElements = List<NoteElementEntity>()
    @objc dynamic var _isDeleted = false
    
    override static func primaryKey() -> String? {
        "_id"
    }
}

class ReminderEntity: Object {
    @objc dynamic var _id = 0
    @objc dynamic var _reminderType = 0
    @objc dynamic var _enabled = false
    @objc dynamic var _reminderCode = 0
    @objc dynamic var _repeatType = 0
    @objc dynamic var _description = ""
    @objc dynamic var _interval = 0
    @objc dynamic var _intervalType = 0
    @objc dynamic var _createdTime = 0
    @objc dynamic var _timeZone = ""
    
    override static func primaryKey() -> String? {
        "_id"
    }
}

class SensorEntity: Object {
    @objc dynamic var _id = 0
    @objc dynamic var _serialNumber = ""
    @objc dynamic var _sensorUID = ""        // BLE address hex
    @objc dynamic var _productType = 0
    @objc dynamic var _localization = 0
    @objc dynamic var _generation = 0
    @objc dynamic var _hwVersion = ""
    @objc dynamic var _swVersion = ""
    @objc dynamic var _fwVersion = ""
    @objc dynamic var _activationDateUtc = 0
    @objc dynamic var _blePIN = ""
    @objc dynamic var _warmupDuration = 0
    @objc dynamic var _wearDuration = 0
    @objc dynamic var _currentLifeCount = 0
    @objc dynamic var _lastHistoricReading = 0  // a lifeCount
    @objc dynamic var _status = 0
    @objc dynamic var _receiverID = 0
    @objc dynamic var _factoryData = ""      // 148 bytes hex (final CRC)
    @objc dynamic var _securityVersion = 0
    @objc dynamic var _lastEvent = 0
    
    override static func primaryKey() -> String? {
        "_id"
    }
}

class SensorEventEntity: Object {
    @objc dynamic var _id = 0
    @objc dynamic var _sensor: SensorEntity?
    @objc dynamic var _lifeCount = 0
    @objc dynamic var _timestampUTC = 0
    @objc dynamic var _eventCode = 0           // SensorEventType
    @objc dynamic var _eventValue = 0.0       // same SensorEventType
    
    override static func primaryKey() -> String? {
        "_id"
    }
}

class SequenceEntity: Object {
    @objc dynamic var _id = 0
    @objc dynamic var _nextSensorId = 0
    @objc dynamic var _nextGlucoseReadingId = 0
    @objc dynamic var _nextSensorEventId = 0
    @objc dynamic var _nextNoteId = 0
    @objc dynamic var _nextNoteElementId = 0
    @objc dynamic var _nextAppConfigId = 0
    @objc dynamic var _nextAppEventId = 0
    @objc dynamic var _nextAlarmConfigId = 0
    @objc dynamic var _nextReminderId = 0
    @objc dynamic var _nextUploadQueueId = 0
}

class UploadQueueRecordEntity: Object {
    @objc dynamic var _id = 0
    @objc dynamic var _recordNumber = 0
    @objc dynamic var _recordType = ""
    
    override static func primaryKey() -> String? {
        "_id"
    }
}

// TODO: verify raw values

extension Libre3 {
    enum UserAccountType {
        case accountUser,
             accountLess,
             accountEmpty,
             accountSwitched,
             accountNotDefined
    }
    
    enum ConfigSource: Int {
        case build    = 1
        case runtime  = 2
    }
    
    enum LifeState: Int {
        case missing         = 1
        case warmup          = 2
        case ready           = 3
        case expired         = 4
        case active          = 5
        case ended           = 6
        case insertionFailed = 7
    }
    
    enum AppEventType: Int {
        case none                = 0
        case bleConnect          = 1
        case bleDisconnect       = 2
        case alarmConfigChanged  = 3
        case alarmStateChanged
        case error
        // Android:
        //   Error(4),
        //   PATCH_WARMUP(5),
        //   PATCH_PAIRED(6),
        //   PATCH_ENDED(7),
        //   FIRST_INIT(8),
        //   LOGGED_IN(9),
        //   NO_PATCH(10),
        //   BleDataCountLow(11),
        //   BleDisconnectsHigh(12),
        //   AppException(13),
        //   AlarmStateChanged(14);
    }
    
    enum EventType: Int {
        case sensorException      = 0
        case newYuUploadFailure   = 1
        case oneStepUploadFailure = 2
        case AppException         = 3
        //   SensorScanUdoLogError(4);
    }
    
    enum SensorEventType: Int {
        case none         = 0
        case activated    = 1
        case connected    = 2
        case disconnected = 3
        case expired      = 4
        case terminated   = 5
        case error        = 6
        // Android:
        //   NONE(0),
        //   WARMINGUP(1),
        //   ACTIVATED(2),
        //   CONNECTED(3),
        //   DISCONNECTED(4),
        //   ENDED(5),
        //   EXPIRED(6),
        //   TERMINATED(7),
        //   ERROR(8);
        
    }
    
    // same as App's GlycemicAlarm
    enum GlycemicAlarmStatus: Int {
        case alarmNotDetermined   = 0
        case lowGlucose           = 1
        case projectedLowGlucose  = 2
        case normalGlucose        = 3
        case projectedHighGlucose = 4
        case highGlucose          = 5
    }
    
    enum AlarmFlag {
        case lowAlarm,
             highAlarm,
             urgentLowAlarm,
             signalLossAlarm
    }
    
    struct GlucoseAlarmState {
        var isPresented: Bool
        var isInEpisode: Bool
        var isDismissed: Bool
        var isCleared: Bool
        var isUserCleared: Bool
    }
    
    struct SignalLossAlarmState {
        var isPresented: Bool
        var isCleared: Bool
        var isUserCleared: Bool
        var isAutoDismissed: Bool
        var isUserDismissed: Bool
    }
    
    struct AlarmStates {
        let lowGlucose:         GlucoseAlarmState
        let highGlucose:        GlucoseAlarmState
        let fixedLowGlucose:    GlucoseAlarmState
        let signalLoss:         SignalLossAlarmState
    }
    
    struct AlarmStateDictionary {
        let episodeFlag: Int
        var states: AlarmStates
    }
    
    // TODO: lowGucoseAlarm, highGlucoseAlarm, fixedLowAlarm, signalLossAlarm JSON decoding when eventType = 4
    
    static let RealmEntityNames = [
        "AlarmConfigEntity",
        "AppConfigEntity",
        "AppEventEntity",
        "GlucoseReadingEntity",
        "NoteElementEntity",
        "NotesEntity",
        "ReminderEntity",
        "SensorEntity",
        "SensorEventEntity",
        "SequenceEntity",
        "UploadQueueRecordEntity"
    ]
    
    // class Libre3.AlarmConfigEntity {
    //     var _id: Swift.Int32
    //     var _alarmType: Swift.Int32
    //     var _enabled: Swift.Bool
    //     var _threshold: Swift.Double
    //     var _soundType: Swift.Int32
    //     var _soundSetting: Swift.String
    //     var _tolerance: Swift.Double
    //     var _f_high: Swift.Double
    //     var _overrideDND: Swift.Bool
    // }
    
    // class Libre3.AppConfigEntity {
    //     var _id: Swift.Int32
    //     var _configName: Swift.String
    //     var _configType: Swift.Int32
    //     var _configValue: Swift.String
    //     var _source: Swift.Int32
    // }
    
    // class Libre3.AppEventEntity {
    //     var _id: Swift.Int32
    //     var _eventType: Swift.Int32
    //     var _eventErrorCode: Swift.Int32
    //     var _timestampUTC: Swift.Int64
    //     var _timestampLocal: Swift.Int64
    //     var _timeZone: Swift.String
    //     var _eventParams: Swift.String
    //     var _eventData: Swift.String
    //     var _display: Swift.Bool
    // }
    
    // class Libre3.GlucoseReadingEntity {
    //     var _id: Swift.Int32
    //     var _sensor: Libre3.SensorEntity?
    //     var _lifeCount: Swift.Int32
    //     var _timestampUTC: Swift.Int64
    //     var _timestampLocal: Swift.Int64
    //     var _timeZone: Swift.String
    //     var _currentGlucose: Swift.Double
    //     var _uncappedGlucose: Swift.Double
    //     var _historicGlucose: Swift.Double
    //     var _trend: Swift.Int32
    //     var _rateOfChange: Swift.Double
    //     var _dqFlag: Swift.Int32
    //     var _historicDqFlag: Swift.Int32
    //     var _actionable: Swift.Int32
    //     var _sensorCondition: Swift.Int32
    //     var _esaDuration: Swift.Int32
    //     var _alarmPresentFlag: Swift.Int16
    //     var _alarmRemoveFlag: Swift.Int16
    //     var _alarmEpisodeFlag: Swift.Int16
    //     var _glycemicAlarmStatus: Swift.Int32
    //     var _projectedGlucose: Swift.Double
    //     var _resultRange: Swift.Int32
    //     var _notes: RealmSwift.List<Libre3.NotesEntity>
    //     var _temperature: Swift.Int32
    //     var _rawData: Swift.String
    //     var _viewed: Swift.Bool
    //     var _extendedUDOflag: Swift.Int16
    //     var _rssi: Swift.Int32
    //     var _isWarmup: Swift.Bool
    //     var _uncappedHistoric: Swift.Double
    //     var _userResultRange: Swift.Int32
    //     var _compositeKey: Swift.Int64
    //     var _stateMap: RealmSwift.List<Swift.Int8>
    //     var _isHistoric: Swift.Bool
    // }
    
    // class Libre3.NoteElementEntity {
    //     var _id: Swift.Int32
    //     var _noteType: Libre3.NoteItemType
    //     var _subType: Swift.Int32
    //     var _value: Swift.Double
    //     var _servingSize: Swift.Double
    // }
    
    // class Libre3.NotesEntity {
    //     var _id: Swift.Int32
    //     var _timestampUTC: Swift.Int64
    //     var _timestampLocal: Swift.Int64
    //     var _timeZone: Swift.String
    //     var _comment: Swift.String?
    //     var _glucoseReading: Libre3.GlucoseReadingEntity?
    //     var _noteElements: RealmSwift.List<Libre3.NoteElementEntity>
    //     var _isDeleted: Swift.Bool
    //     var reading: Libre3.Reading?
    //     let glucoseReading: RealmSwift.LinkingObjects<Libre3.GlucoseReadingEntity>
    // }
    
    // class Libre3.ReminderEntity {
    //     var _id: Swift.Int32
    //     var _reminderType: Swift.Int32
    //     var _enabled: Swift.Bool
    //     var _reminderCode: Swift.Int32
    //     var _repeatType: Swift.Int32
    //     var _description: Swift.String
    //     var _interval: Swift.Int32
    //     var _intervalType: Swift.Int32
    //     var _createdTime: Swift.Int64
    //     var _timeZone: Swift.String
    // }
    
    // class Libre3.SensorEntity {
    //     var _id: Swift.Int32
    //     var _serialNumber: Swift.String
    //     var _sensorUID: Swift.String
    //     var _productType: Swift.Int32
    //     var _localization: Swift.Int32
    //     var _generation: Swift.Int32
    //     var _hwVersion: Swift.String
    //     var _swVersion: Swift.String
    //     var _fwVersion: Swift.String
    //     var _activationDateUtc: Swift.Int64
    //     var _blePIN: Swift.String
    //     var _warmupDuration: Swift.Int32
    //     var _wearDuration: Swift.Int32
    //     var _currentLifeCount: Swift.Int32
    //     var _lastHistoricReading: Swift.Int32
    //     var _status: Swift.Int32
    //     var _receiverID: Swift.Int64
    //     var _factoryData: Swift.String
    //     var _securityVersion: Swift.Int32
    //     var _lastEvent: Swift.Int32
    // }
    
    // class Libre3.SensorEventEntity {
    //     var _id: Swift.Int32
    //     var _sensor: Libre3.SensorEntity?
    //     var _lifeCount: Swift.Int32
    //     var _timestampUTC: Swift.Int64
    //     var _eventCode: Swift.Int32
    //     var _eventValue: Swift.Double
    // }
    
    // class Libre3.SequenceEntity {
    //     var _id: Swift.Int32
    //     var _nextSensorId: Swift.Int32
    //     var _nextGlucoseReadingId: Swift.Int32
    //     var _nextSensorEventId: Swift.Int32
    //     var _nextNoteId: Swift.Int32
    //     var _nextNoteElementId: Swift.Int32
    //     var _nextAppConfigId: Swift.Int32
    //     var _nextAppEventId: Swift.Int32
    //     var _nextAlarmConfigId: Swift.Int32
    //     var _nextReminderId: Swift.Int32
    //     var _nextUploadQueueId: Swift.Int32
    // }
    
    // class Libre3.UploadQueueRecordEntity {
    //     var _id: Swift.Int32
    //     var _recordNumber: Swift.Int64
    //     var _recordType: Swift.String
    // }
    
    // TODO: parse flatted JSON: https://github.com/WebReflection/flatted
    
    func parseRealmFlattedJson(data: Data) {
        var entityRowsCount: [String: Int] = [:]
        var entityStartIndex: [String: Int] = [:]
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [Any] {
            let entities = (json[0] as! [String: String]).sorted { Int($0.value)! < Int($1.value)! }
            log("Realm: trident.json tables: \(entities)")
            var index = 1
            
            for (i, entity) in entities.enumerated() {
                let indexes = (json[i + 1] as! [String])
                let rowsCount = indexes.count
                entityStartIndex[entity.key] = Int(indexes.first ?? "0")
                entityRowsCount[entity.key] = rowsCount
                log("\(entity.key): \(indexes.count) rows, indexes: \(indexes.first ?? "0") - \(indexes.last ?? "0")")
                
                switch entity.key {
                    
                case "AppConfigEntity":
                    for i in 0 ..< rowsCount {
                        let entityJson = json[entityStartIndex[entity.key]! + i] as! [String: Any]
                        let configName = json[Int(entityJson["_configName"]! as! String)!] as! String
                        let configValue = json[Int(entityJson["_configValue"]! as! String)!] as! String
                        log("Realm: \(entity.key) #\(i+1) of \(rowsCount) JSON: \(entityJson), configName = \(configName), configValue = \(configValue)")
                    }
                    
                case "GlucoseReadingEntity":
                    var sensorsCount: Int64 = 0
                    
                    for i in 0 ..< rowsCount {
                        let j = rowsCount - i - 1
                        let entityJson = json[entityStartIndex[entity.key]! + j] as! [String: Any]
                        let compositeKey = entityJson["_compositeKey"]! as! Int64
                        let sensorID = compositeKey >> 32
                        
                        if sensorID < sensorsCount {
                            break
                        } else {
                            sensorsCount = sensorID
                        }
                        
                        // let sensor = json[Int(entityJson["_sensor"]! as! String)!]
                        let lifeCount = entityJson["_lifeCount"]! as! Int
                        let timestampUTC = entityJson["_timestampUTC"]! as! Int64
                        let currentGlucose = entityJson["_currentGlucose"]! as! Double
                        let historicGlucose = entityJson["_historicGlucose"]! as! Double
                        let trend = entityJson["_trend"]! as! Int
                        let rateOfChange = entityJson["_rateOfChange"]! as! Double
                        let glycemicAlarmStatus = entityJson["_glycemicAlarmStatus"]! as! Int
                        let projectedGlucose = entityJson["_projectedGlucose"]! as! Double
                        let temperature = entityJson["_temperature"]! as! Int
                        let rawData = (json[Int(entityJson["_rawData"]! as! String)!] as! String).trimmingCharacters(in: .whitespaces)
                        
                        let date = Date(timeIntervalSince1970: Double(timestampUTC) / 1000)
                        let trendArrow = TrendArrow(rawValue: trend)!
                        let glycemicAlarm = GlycemicAlarm(rawValue: glycemicAlarmStatus)!
                        
                        log("Realm: \(entity.key) #\(j+1) of \(rowsCount) JSON: \(entityJson), lifeCount: \(lifeCount), currentGlucose: \(currentGlucose), historicGlucose: \(historicGlucose), date: \(date.local), trend arrow: \(trendArrow), rate of change: \(rateOfChange / 100), glycemic alarm: \(glycemicAlarm), projected glucose: \(projectedGlucose / 100), temperature: \(Double(temperature) / 100), raw data: \(rawData), sensor id: \(sensorID)")
                    }
                    
                case "SensorEntity":
                    for i in 0 ..< rowsCount {
                        let entityJson = json[entityStartIndex[entity.key]! + i] as! [String: Any]
                        let serialNumber = json[Int(entityJson["_serialNumber"]! as! String)!] as! String
                        let sensorUID = json[Int(entityJson["_sensorUID"]! as! String)!] as! String
                        let hwVersion = json[Int(entityJson["_hwVersion"]! as! String)!] as! String
                        let swVersion = json[Int(entityJson["_swVersion"]! as! String)!] as! String
                        let fwVersion = json[Int(entityJson["_fwVersion"]! as! String)!] as! String
                        let blePIN = (json[Int(entityJson["_blePIN"]! as! String)!] as! String).trimmingCharacters(in: .whitespaces)
                        let factoryData = (json[Int(entityJson["_factoryData"]! as! String)!] as! String).trimmingCharacters(in: .whitespaces)
                        
                        log("Realm: \(entity.key) #\(i+1) of \(rowsCount) JSON: \(entityJson), serialNumber: \(serialNumber), sensorUID: \(sensorUID), hwVersion: \(hwVersion), swVersion: \(swVersion), fwVersion: \(fwVersion),  blePIN: \(blePIN), factoryData: \(factoryData)")
                    }
                    
                default:
                    break
                }
                
                index += rowsCount
            }
        }
    }
}
