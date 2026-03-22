import Foundation

struct EventReport {
    static let configurationNotification = 3356
    static let segmentDataNotification = 3361
    
    let handle: Int
    let relativeTime: Int
    let eventType: Int
    let configuration: Configuration?
    let instance: Int
    let index: Int
    let insulinDoses: [InsulinDoseRecord]
    
    init(reader: inout ByteReader) throws {
        handle = Int(try reader.readUInt16())
        relativeTime = Int(try reader.readInt32())
        eventType = Int(try reader.readUInt16())
        _ = Int(try reader.readUInt16())
        
        switch eventType {
        case Self.segmentDataNotification:
            instance = Int(try reader.readUInt16())
            index = Int(try reader.readInt32())
            let count = Int(try reader.readInt32())
            _ = Int(try reader.readUInt16())
            _ = Int(try reader.readUInt16())
            
            var insulinDoses: [InsulinDoseRecord] = []
            for _ in 0 ..< count {
                let dose = try InsulinDoseRecord(reader: &reader)
                if dose.isValid {
                    insulinDoses.append(dose)
                }
            }
            
            configuration = nil
            self.insulinDoses = insulinDoses
        case Self.configurationNotification:
            configuration = try Configuration(reader: &reader)
            instance = -1
            index = -1
            insulinDoses = []
        default:
            configuration = nil
            instance = -1
            index = -1
            insulinDoses = []
        }
    }
}
