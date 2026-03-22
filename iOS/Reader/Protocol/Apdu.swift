import Foundation

struct Apdu {
    static let aarq = 0xE200
    static let aare = 0xE300
    static let rlrq = 0xE400
    static let rlre = 0xE500
    static let abrt = 0xE600
    static let prst = 0xE700
    
    let at: Int
    let payload: Data
    
    init(at: Int, payload: Data) {
        self.at = at
        self.payload = payload
    }
    
    init(data: Data) throws {
        var reader = ByteReader(data: data)
        at = Int(try reader.readUInt16())
        let length = Int(try reader.readUInt16())
        payload = try reader.readData(count: length)
    }
    
    func encoded() -> Data {
        var writer = ByteWriter()
        writer.writeUInt16(at)
        writer.writeUInt16(payload.count)
        writer.writeData(payload)
        return writer.data
    }
    
    var typeName: String {
        switch at {
        case Self.aarq: "AARQ"
        case Self.aare: "AARE"
        case Self.rlrq: "RLRQ"
        case Self.rlre: "RLRE"
        case Self.abrt: "ABRT"
        case Self.prst: "PRST"
        default: "0x" + String(at, radix: 16, uppercase: true)
        }
    }
}
