import Foundation

struct ApoepElement {
    static let protocolIdentifier = 20_601
    static let systemTypeManager = 0x80000000
    
    var version: Int
    var encoding: Int
    var nomenclature: Int
    var functional: Int
    var systemType: Int
    var systemID: Data
    var configID: Int
    var recMode: Int
    var listCount: Int
    var listLength: Int
    
    init(reader: inout ByteReader) throws {
        version = Int(try reader.readInt32())
        encoding = Int(try reader.readUInt16())
        nomenclature = Int(try reader.readInt32())
        functional = Int(try reader.readInt32())
        systemType = Int(try reader.readInt32())
        let systemIDLength = Int(try reader.readUInt16())
        systemID = try reader.readData(count: systemIDLength)
        configID = Int(try reader.readUInt16())
        recMode = Int(try reader.readInt32())
        listCount = Int(try reader.readUInt16())
        listLength = Int(try reader.readUInt16())
    }
    
    func encoded() -> Data {
        var writer = ByteWriter()
        writer.writeInt32(version)
        writer.writeUInt16(encoding)
        writer.writeInt32(nomenclature)
        writer.writeInt32(functional)
        writer.writeInt32(systemType)
        writer.writeUInt16(systemID.count)
        writer.writeData(systemID)
        writer.writeUInt16(configID)
        writer.writeInt32(recMode)
        writer.writeUInt16(listCount)
        writer.writeUInt16(listLength)
        return writer.data
    }
}
