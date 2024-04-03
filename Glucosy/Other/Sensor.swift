import Foundation

#if !os(watchOS)
import CoreNFC
#endif

enum SensorType: String, CustomStringConvertible {
    case libre1        = "Libre 1"
    case libreUS14day  = "Libre US 14d"
    case libreProH     = "Libre Pro/H"
    case libre2        = "Libre 2"
    case libre2US      = "Libre 2 US"
    case libre2CA      = "Libre 2 CA"
    case libre2RU      = "Libre 2 RU"
    case libreSense    = "Libre Sense"
    case libre2Plus    = "Libre 2 Plus"
    case libre3        = "Libre 3"
    case dexcomG6      = "Dexcom G6"
    case dexcomONE     = "Dexcom ONE"
    case dexcomG7      = "Dexcom G7"
    case dexcomONEPlus = "Dexcom ONE+"
    case unknown       = "unknown"
    
    var description: String {
        rawValue
    }
    
    var isALibre: Bool {
        self == .libre3 ||
        self == .libre2 ||
        self == .libre1 ||
        self == .libreUS14day ||
        self == .libreProH ||
        self == .libre2US ||
        self == .libre2CA ||
        self == .libre2RU ||
        self == .libreSense
    }
}

enum SensorFamily: Int, CustomStringConvertible {
    case unknown    = -1
    case libre1     = 0
    case librePro   = 1
    case libre2     = 3
    case libre3     = 4
    case libreSense = 7
    
    var description: String {
        switch self {
        case .unknown:    "unknown"
        case .libre1:     "Libre 1"
        case .librePro:   "Libre Pro"
        case .libre2:     "Libre 2"
        case .libre3:     "Libre 3"
        case .libreSense: "Libre Sense"
        }
    }
}

enum SensorRegion: Int, CustomStringConvertible {
    case unknown            = 0
    case european           = 1
    case usa                = 2
    case australianCanadian = 4
    case easternROW         = 8
    
    var description: String {
        switch self {
        case .unknown:            "unknown"
        case .european:           "European"
        case .usa:                "USA"
        case .australianCanadian: "Australian / Canadian"
        case .easternROW:         "Eastern / Rest of World"
        }
    }
}

enum SensorState: UInt8, CustomStringConvertible {
    case unknown      = 0x00
    case notActivated = 0x01
    case warmingUp    = 0x02 // 60 minutes
    case active       = 0x03 // ≈ 14.5 days
    case expired      = 0x04 // 12 hours more; Libre 2: Bluetooth shutdown
    case shutdown     = 0x05 // 15th day onwards
    case failure      = 0x06
    
    var description: String {
        switch self {
        case .notActivated: "Not activated"
        case .warmingUp:    "Warming up"
        case .active:       "Active"
        case .expired:      "Expired"
        case .shutdown:     "Shut down"
        case .failure:      "Failure"
        default:            "unknown"
        }
    }
}

@Observable class Sensor: Logging {
    var type: SensorType = .unknown
    var family: SensorFamily = .unknown
    var region: SensorRegion = .unknown
    var serial = ""
    var readerSerial = Data()
    var firmware = ""
    
    var transmitter: Transmitter?
    var main: MainDelegate!
    
    var state: SensorState = .unknown
    var lastReadingDate: Date = .distantPast
    var activationTime: UInt32 = 0
    var age = 0
    var maxLife = 0
    var initializations = 0
    
    var crcReport = ""
    
    var securityGeneration = 0
    
    var patchInfo: PatchInfo = Data() {
        willSet(info) {
            if info.count > 0 {
                type = SensorType(patchInfo: info)
            } else {
                type = .unknown
            }
            
            if type != .libre3 {
                if info.count > 3 {
                    region = SensorRegion(rawValue: Int(info[3])) ?? .unknown
                }
                
                if info.count >= 6 {
                    family = SensorFamily(rawValue: Int(info[2] >> 4)) ?? .libre1
                    
                    if serial != "" {
                        serial = "\(family.rawValue)\(serial.dropFirst())"
                    }
                    
                    let generation = info[2] & 0x0F
                    
                    if family == .libre2 {
                        securityGeneration = generation < 9 ? 1 : 2
                    }
                    
                    if family == .libreSense {
                        securityGeneration = generation < 4 ? 1 : 2
                    }
                }
            } else {
                family = .libre3
                region = SensorRegion(rawValue: Int(UInt16(info[2...3]))) ?? .unknown
                securityGeneration = 3 // TODO
            }
        }
    }
    
    var uid: SensorUid = Data() {
        willSet(uid) {
            if type != .libre3 {
                serial = serialNumber(uid: uid, family: self.family)
            }
        }
    }
    
    var trend:   [Glucose] = []
    var history: [Glucose] = []
    
    var calibrationInfo = CalibrationInfo()
    
    var factoryTrend: [Glucose] {
        trend.map {
            factoryGlucose(rawGlucose: $0, calibrationInfo: calibrationInfo)
        }
    }
    
    var factoryHistory: [Glucose] {
        history.map {
            factoryGlucose(rawGlucose: $0, calibrationInfo: calibrationInfo)
        }
    }
    
    var encryptedFram = Data()
    
    @ObservationIgnored
    var fram = Data() {
        didSet {
            encryptedFram = Data()
            
            if (family == .libre2 || type == .libreUS14day) && UInt16(fram[0...1]) != crc16(fram[2...23]) {
                encryptedFram = fram
                
                if fram.count >= 344 {
                    if let decryptedFRAM = try? Libre2.decryptFRAM(type: type, id: uid, info: patchInfo, data: fram) {
                        fram = decryptedFRAM
                    }
                }
            }
            
            parseFRAM()
        }
    }
    
    // Libre 2 and BLE streaming parameters
    var initialPatchInfo: PatchInfo = Data()
    var streamingUnlockCode:  UInt32 = 42
    var streamingUnlockCount: UInt16 = 0
    
    // Gen2
    var streamingContext = 0    // returned by getNfcAuthenticatedCommandBLE(command:...)
    
    /// formed when passed as third inout argument to verifyEnableStreamingResponse()
    /// 10 bytes in older US2 models, 12 bytes in new  ones
    var streamingAuthenticationData = Data()
    
    init(transmitter: Transmitter? = nil, main: MainDelegate? = nil) {
        self.transmitter = transmitter
        
        if transmitter != nil {
            self.main = transmitter!.main
        } else {
            self.main = main
        }
    }
    
    func parseFRAM() {
        updateCRCReport()
        
        guard crcReport.contains("OK") else {
            state = .unknown
            return
        }
        
        if fram.count < 344 && encryptedFram.count > 0 {
            return
        }
        
        if let sensorState = SensorState(rawValue: fram[4]) {
            state = sensorState
        }
        
        guard fram.count >= 320 else {
            return
        }
        
        age = Int(fram[316]) + Int(fram[317]) << 8 // body[-4]
        
        let startDate = lastReadingDate - Double(age) * 60
        initializations = Int(fram[318])
        
        trend = []
        history = []
        
        let trendIndex = Int(fram[26])   // body[2]
        let historyIndex = Int(fram[27]) // body[3]
        
        for i in 0...15 {
            var j = trendIndex - 1 - i
            
            if j < 0 {
                j += 16
            }
            
            let offset = 28 + j * 6     // body[4..<100]
            let rawValue =              readBits(fram, offset, 0, 0xe)
            let quality =               UInt16(readBits(fram, offset, 0xe, 0xb)) & 0x1FF
            let qualityFlags =          (readBits(fram, offset, 0xe, 0xb) & 0x600) >> 9
            let hasError =              readBits(fram, offset, 0x19, 0x1) != 0
            let rawTemperature =        readBits(fram, offset, 0x1a, 0xc) << 2
            var temperatureAdjustment = readBits(fram, offset, 0x26, 0x9) << 2
            let negativeAdjustment =    readBits(fram, offset, 0x2f, 0x1)
            
            if negativeAdjustment != 0 {
                temperatureAdjustment = -temperatureAdjustment
            }
            
            let id = age - i
            let date = startDate + Double(age - i) * 60
            
            trend.append(.init(
                rawValue: rawValue,
                rawTemperature: rawTemperature,
                temperatureAdjustment: temperatureAdjustment,
                id: id,
                date: date,
                hasError: hasError,
                dataQuality: .init(rawValue: Int(quality)),
                dataQualityFlags: qualityFlags
            ))
        }
        
        // FRAM is updated with a 3 minutes delay:
        // https://github.com/UPetersen/LibreMonitor/blob/Swift4/LibreMonitor/Model/SensorData.swift
        
        let preciseHistoryIndex = ((age - 3) / 15) % 32
        let delay = (age - 3) % 15 + 3
        var readingDate = lastReadingDate
        
        if preciseHistoryIndex == historyIndex {
            readingDate.addTimeInterval(60 * -Double(delay))
        } else {
            readingDate.addTimeInterval(60 * -Double(delay - 15))
        }
        
        for i in 0...31 {
            var j = historyIndex - 1 - i
            
            if j < 0 {
                j += 32
            }
            
            let offset =                124 + j * 6 // body[100..<292]
            let rawValue =              readBits(fram, offset, 0, 0xe)
            let quality =               UInt16(readBits(fram, offset, 0xe, 0xb)) & 0x1FF
            let qualityFlags =          (readBits(fram, offset, 0xe, 0xb) & 0x600) >> 9
            let hasError =              readBits(fram, offset, 0x19, 0x1) != 0
            let rawTemperature =        readBits(fram, offset, 0x1a, 0xc) << 2
            var temperatureAdjustment = readBits(fram, offset, 0x26, 0x9) << 2
            let negativeAdjustment =    readBits(fram, offset, 0x2f, 0x1)
            
            if negativeAdjustment != 0 {
                temperatureAdjustment = -temperatureAdjustment
            }
            
            let id = age - delay - i * 15
            let date = id > -1 ? readingDate - Double(i) * 900 : startDate /// 15 * 60
            
            history.append(.init(
                rawValue: rawValue,
                rawTemperature: rawTemperature,
                temperatureAdjustment: temperatureAdjustment,
                id: id,
                date: date,
                hasError: hasError,
                dataQuality: .init(rawValue: Int(quality)),
                dataQualityFlags: qualityFlags
            ))
        }
        
        guard fram.count >= 344 else {
            return
        }
        
        // fram[322...323] (footer[2..3]) corresponds to patchInfo[2...3]
        region = SensorRegion(rawValue: Int(fram[323])) ?? .unknown
        maxLife = Int(fram[326]) + Int(fram[327]) << 8
        
        DispatchQueue.main.async { [self] in
            main?.settings.activeSensorMaxLife = maxLife
        }
        
        let i1 = readBits(fram, 2, 0, 3)
        let i2 = readBits(fram, 2, 3, 0xa)
        let i3 = readBits(fram, 0x150, 0, 8) // footer[-8]
        let i4 = readBits(fram, 0x150, 8, 0xe)
        let i5 = readBits(fram, 0x150, 0x28, 0xc) << 2
        let i6 = readBits(fram, 0x150, 0x34, 0xc) << 2
        let negativei3 = readBits(fram, 0x150, 0x21, 1) != 0
        
        calibrationInfo = CalibrationInfo(i1: i1, i2: i2, i3: negativei3 ? -i3 : i3, i4: i4, i5: i5, i6: i6)
        
        DispatchQueue.main.async { [self] in
            main?.settings.activeSensorCalibrationInfo = calibrationInfo
        }
    }
    
    func detailFRAM() {
        if encryptedFram.count > 0 && fram.count >= 344 {
            log("\(fram.hexDump(header: "Sensor decrypted FRAM:", startBlock: 0))")
        }
        
        if crcReport.count > 0 {
            log(crcReport)
            
            if !crcReport.contains("OK") {
                if history.count > 0 && type != .libre2 { // bogus raw data with Libre 1
                    main?.errorStatus("Error while validating sensor data")
                    return
                }
            }
        }
        
        log("Sensor state: \(state.description.lowercased()) (0x\(state.rawValue.hex))")
        
        if state == .failure {
            let errorCode = fram[6]
            let failureAge = Int(fram[7]) + Int(fram[8]) << 8
            let failureInterval = failureAge == 0 ? "an unknown time" : "\(failureAge) minutes (\(failureAge.formattedInterval))"
            
            log("Sensor failure error 0x\(errorCode.hex) (\(decodeFailure(error: errorCode))) at \(failureInterval) after activation.")
        }
        
        if fram.count >= 344 && !crcReport.contains("FAILED") {
            if settings.userLevel > .basic {
                log("Sensor factory values: raw minimum threshold: \(fram[330]) (tied to SENSOR_SIGNAL_LOW error, should be 150 for a Libre 1), maximum ADC delta: \(fram[332]) (tied to FILTER_DELTA error, should be 90 for a Libre 1)")
            }
            
            if initializations > 0 {
                log("Sensor initializations: \(initializations)")
            }
            
            log("Sensor region: \(region.description) (0x\(fram[323].hex))")
        }
        
        if maxLife > 0 {
            log("Sensor maximum life: \(maxLife) minutes (\(maxLife.formattedInterval))")
        }
        
        if age > 0 {
            log("Sensor age: \(age) minutes (\(age.formattedInterval))")
            log("Started on: \((lastReadingDate - Double(age) * 60).shortDateTime)")
        }
    }
    
    func updateCRCReport() {
        if fram.count < 344 {
            crcReport = "NFC: FRAM read did not complete: can't verify CRC"
            
        } else {
            let headerCRC = UInt16(fram[0...1])
            let bodyCRC   = UInt16(fram[24...25])
            let footerCRC = UInt16(fram[320...321])
            let computedHeaderCRC = crc16(fram[2...23])
            let computedBodyCRC   = crc16(fram[26...319])
            let computedFooterCRC = crc16(fram[322...343])
            
            var report = "Sensor header CRC16: \(headerCRC.hex), computed: \(computedHeaderCRC.hex) -> \(headerCRC == computedHeaderCRC ? "OK" : "FAILED")"
            report += "\nSensor body CRC16: \(bodyCRC.hex), computed: \(computedBodyCRC.hex) -> \(bodyCRC == computedBodyCRC ? "OK" : "FAILED")"
            report += "\nSensor footer CRC16: \(footerCRC.hex), computed: \(computedFooterCRC.hex) -> \(footerCRC == computedFooterCRC ? "OK" : "FAILED")"
            
            if fram.count >= 1904 { /// 344 + 195 * 8
                let commandsCRC = UInt16(fram[344...345])
                let computedCommandsCRC = crc16(fram[346..<1904]) /// 344 + 195 * 8
                ///
                report += "\nSensor commands CRC16: \(commandsCRC.hex), computed: \(computedCommandsCRC.hex) -> \(commandsCRC == computedCommandsCRC ? "OK" : "FAILED")"
            }
            
            crcReport = report
        }
    }
    
#if !os(watchOS)
    func execute(nfc: NFC, taskRequest: TaskRequest) async throws {
        
    }
#endif
}
