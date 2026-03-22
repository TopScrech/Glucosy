import Foundation

struct Specification {
    let serial: String
    let partNumber: String
    let hardwareRevision: String
    let softwareRevision: String
    
    init(
        serial: String = "",
        partNumber: String = "",
        hardwareRevision: String = "",
        softwareRevision: String = ""
    ) {
        self.serial = serial
        self.partNumber = partNumber
        self.hardwareRevision = hardwareRevision
        self.softwareRevision = softwareRevision
    }
    
    init(reader: inout ByteReader) throws {
        let count = Int(try reader.readUInt16())
        _ = Int(try reader.readUInt16())
        
        var serial = ""
        var partNumber = ""
        var hardwareRevision = ""
        var softwareRevision = ""
        
        for _ in 0 ..< count {
            let type = Int(try reader.readUInt16())
            _ = Int(try reader.readUInt16())
            let value = try reader.readIndexedString()
            
            switch type {
            case 1:
                serial = value
            case 2:
                partNumber = value
            case 3:
                hardwareRevision = value
            case 4:
                softwareRevision = value
            default:
                break
            }
        }
        
        self.serial = serial
        self.partNumber = partNumber
        self.hardwareRevision = hardwareRevision
        self.softwareRevision = softwareRevision
    }
}
