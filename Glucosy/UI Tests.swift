import Foundation

extension AppState {
    static func test(tab: Tab) -> AppState {
        let main = MainDelegate()
        let app = main.app
        
        let transmitter = Abbott(main: main)
        transmitter.type = .transmitter(.abbott)
        transmitter.name = "Thingy"
        transmitter.battery = 54
        transmitter.rssi = -75
        transmitter.firmware = "4.56"
        transmitter.manufacturer = "Acme Inc."
        transmitter.hardware = "2.3"
        transmitter.macAddress = Data([0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF])
        transmitter.state = .connected
        transmitter.lastConnectionDate = Date() - 5
        
        app.transmitter = transmitter
        app.device = app.transmitter
        app.lastConnectionDate = transmitter.lastConnectionDate
        app.lastReadingDate = transmitter.lastConnectionDate
        
        let sensor = Sensor(transmitter: transmitter, main: main)
        sensor.state = .active; sensor.serial = "3MH001DG75W"
        sensor.age = 18705
        sensor.uid = "2fe7b10000a407e0".bytes
        sensor.patchInfo = "9d083001712b".bytes
        
        app.sensor = sensor
        app.device.serial = sensor.serial
        
        app.main.settings.selectedTab = tab
        app.currentGlucose = 234
        app.trendDelta = -12
        app.trendDeltaMinutes = 6
        app.glycemicAlarm = .highGlucose
        app.trendArrow = .falling
        app.deviceState = "Connected"
        app.status = "Sensor + Transmitter\nError about connection\nError about sensor"
        
        return app
    }
}

extension History {
    static var test: History {
        let history = History()
        
        let values = [231, 252, 253, 254, 245, 196, 177, 128, 149, 150, 101, 122, 133, 144, 155, 166, 177, 178, 149, 140, 141, 142, 143, 144, 155, 166, 177, 178, 169, 150, 141, 132].enumerated().map {
            Glucose($0.1, id: 5000 - $0.1 * 15, date: Date() - Double($0.1) * 15 * 60)
        }
        history.values = values
        
        let rawValues = [241, 252, 263, 254, 205, 196, 187, 138, 159, 160, 121, 132, 133, 154, 165, 176, 157, 148, 149, 140, 131, 132, 143, 154, 155, 176, 177, 168, 159, 150, 142].enumerated().map {
            Glucose($0.1, id: 5000 - $0.0 * 15, date: Date() - Double($0.1) * 15 * 60)
        }
        history.rawValues = rawValues
        
        let factoryArray = [231, 242, 243, 244, 255, 216, 197, 138, 159, 120, 101, 102, 143, 154, 165, 186, 187, 168, 139, 130, 131, 142, 143, 144, 155, 166, 177, 188, 169, 150, 141, 132]
        
        let factoryValues = factoryArray.enumerated().map {
            Glucose($0.1, id: 5000 - $0.1 * 15, date: Date() - Double($0.1) * 15 * 60)
        }
        history.factoryValues = factoryValues
        
        let rawTrend = [241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 241, 242, 243, 244, 245].enumerated().map {
            Glucose($0.1, id: 5000 - $0.0, date: Date() - Double($0.1) * 60)
        }
        history.rawTrend = rawTrend
        
        let factoryTrend = [231, 232, 233, 234, 235, 236, 237, 238, 239, 230, 231, 232, 233, 234, 235].enumerated().map {
            Glucose($0.1, id: 5000 - $0.0, date: Date() - Double($0.1) * 60)
        }
        history.factoryTrend = factoryTrend
        
        let storedValues = [231, 252, 253, 254, 245, 196, 177, 128, 149, 150, 101, 122, 133, 144, 155, 166, 177, 178, 149, 140, 141, 142, 143, 144, 155, 166, 177, 178, 169, 150, 141, 132].enumerated().map {
            Glucose($0.1, id: $0.0, date: Date() - Double($0.1) * 15 * 60, source: "SourceApp com.example.sourceapp")
        }
        history.storedValues = storedValues
        
        let nightscoutValues = [231, 252, 253, 254, 245, 196, 177, 128, 149, 150, 101, 122, 133, 144, 155, 166, 177, 178, 149, 140, 141, 142, 143, 144, 155, 166, 177, 178, 169, 150, 141, 132].enumerated().map {
            Glucose($0.1, id: $0.0, date: Date() - Double($0.1) * 15 * 60, source: "Device")
        }
        history.nightscoutValues = nightscoutValues
        
        return history
    }
}
