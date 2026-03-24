import Foundation

struct InsulinDoseRecord {
    static let validFlag = 0x08000000
    static let encodedUnitsMask: UInt32 = 0xFFFF0000
    static let encodedUnitsPrefix: UInt32 = 0xFF000000
    
    let time: Int
    let units: Int
    let flags: Int
    
    init(reader: inout ByteReader) throws {
        time = Int(try reader.readInt32())
        let encodedUnits = UInt32(bitPattern: try reader.readInt32())
        
        units = (encodedUnits & Self.encodedUnitsMask) == Self.encodedUnitsPrefix
        ? Int(encodedUnits & 0xFFFF)
        : -1
        
        flags = Int(try reader.readInt32())
    }
    
    var isValid: Bool {
        flags == Self.validFlag && units > 0
    }
    
    func resolvedDate(relativeTime: Int, currentTime: Date) -> Date {
        let delta = TimeInterval(relativeTime - time)
        return currentTime.addingTimeInterval(-delta)
    }
}
