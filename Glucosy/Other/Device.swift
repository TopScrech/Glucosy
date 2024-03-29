import CoreBluetooth

enum DeviceType: CaseIterable, Hashable, Identifiable {
    case none
    case transmitter(TransmitterType)
    case watch(WatchType)
    
    static var allCases: [DeviceType] {
        TransmitterType.allCases.map { 
            .transmitter($0)
        } // + WatchType.allCases.map{ .watch($0) }
    }
    
    var id: String {
        switch self {
        case .none:                  "none"
        case .transmitter(let type): type.id
        case .watch(let type):       type.id
        }
    }
    
    var type: AnyClass {
        switch self {
        case .none:                  Device.self
        case .transmitter(let type): type.type
        case .watch(let type):       type.type
        }
    }
}

@Observable // not final
class Device: Logging {
    class var type: DeviceType { .none }
    class var name: String { "Unknown" }
    
    class var knownUUIDs: [String] { [] }
    class var dataServiceUUID:             String { "" }
    class var dataReadCharacteristicUUID:  String { "" }
    class var dataWriteCharacteristicUUID: String { "" }
    
    var type: DeviceType = .none
    var name = "Unknown"
    
    var main: MainDelegate!
    
    var peripheral: CBPeripheral?
    var characteristics = [String: CBCharacteristic]()
    
    /// Updated when notified by the Bluetooth manager
    var state: CBPeripheralState = .disconnected
    var lastConnectionDate: Date = .distantPast
    
    var readCharacteristic: CBCharacteristic?
    var writeCharacteristic: CBCharacteristic?
    
    var battery = -1
    var rssi = 0
    var company = ""
    var model = ""
    var serial = ""
    var firmware = ""
    var hardware = ""
    var software = ""
    var manufacturer = ""
    var macAddress = Data()
    var buffer = Data()
    
    init(peripheral: CBPeripheral, main: MainDelegate) {
        self.type = Self.type
        self.name = Self.name
        self.peripheral = peripheral
        self.main = main
    }
    
    init() {
        self.type = Self.type
        self.name = Self.name
    }
    
    // For log while testing
    convenience init(main: MainDelegate) {
        self.init()
        self.main = main
    }
    
    func write(_ data: Data, for uuid: String = "", _ writeType: CBCharacteristicWriteType = .withoutResponse) {
        if uuid.isEmpty {
            if writeCharacteristic != nil {
                peripheral?.writeValue(data, for: writeCharacteristic!, type: writeType)
            } else {
                log("Bluetooth: \(name)'s write characteristic undefined: couldn't write")
            }
        } else {
            peripheral?.writeValue(data, for: characteristics[uuid]!, type: writeType)
        }
    }
    
    func read(_ data: Data, for uuid: String) {
        
    }
    
    func readValue(for uuid: String = "") {
        if let characteristic = characteristics[uuid] ?? readCharacteristic {
            peripheral?.readValue(for: characteristic)
            
            debugLog("\(name): requested value for \(!uuid.isEmpty ? uuid : "read") characteristic")
        } else {
            debugLog("\(name): cannot read value for unknown characteristic \(uuid)")
        }
    }
    
    /// varying reading interval
    func readCommand(interval: Int = 5) -> Data {
        Data()
    }
    
    func parseManufacturerData(_ data: Data) {
        log("Bluetooth: \(name)'s advertised manufacturer data: \(data.hex)" )
    }
}

enum TransmitterType: String, CaseIterable, Hashable, Codable, Identifiable {
    case none, abbott, dexcom
    var id: String { 
        rawValue
    }
    
    var name: String {
        switch self {
        case .none:   "Any"
        case .abbott: Abbott.name
        case .dexcom: Dexcom.name
        }
    }
    var type: AnyClass {
        switch self {
        case .none:   Transmitter.self
        case .abbott: Abbott.self
        case .dexcom: Dexcom.self
        }
    }
}

@Observable // not final
class Transmitter: Device {
    var sensorUid: SensorUid = Data()
    var sensor: Sensor?
}

enum WatchType: String, CaseIterable, Hashable, Codable, Identifiable {
    case none, 
         appleWatch
    
    var id: String {
        rawValue
    }
    
    var name: String {
        switch self {
        case .none:       "Any"
        case .appleWatch: AppleWatch.name
        }
    }
    
    var type: AnyClass {
        switch self {
        case .none:       Watch.self
        case .appleWatch: AppleWatch.self
        }
    }
}

@Observable // not final
class Watch: Device {
    override class var type: DeviceType {
        DeviceType.watch(.none)
    }
    
    var transmitter: Transmitter? = Transmitter()
}

@Observable
final class AppleWatch: Watch {
    override class var type: DeviceType {
        DeviceType.watch(.appleWatch)
    }
    
    override class var name: String { 
        "Apple Watch"
    }
}
