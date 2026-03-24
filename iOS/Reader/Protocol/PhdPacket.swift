import Foundation

struct PhdPacket {
    private static let messageBegin = 1 << 7
    private static let messageEnd = 1 << 6
    private static let shortRecord = 1 << 4
    private static let idLengthPresent = 1 << 3
    private static let wellKnown = 1
    
    let sequence: Int
    let checksum: Int
    let content: Data
    let header: Data?
    
    init(sequence: Int, checksum: Int = 0, content: Data, header: Data? = nil) {
        self.sequence = sequence
        self.checksum = checksum
        self.content = content
        self.header = header
    }
    
    init(reader: inout ByteReader) throws {
        let opcode = Int(try reader.readUInt8())
        _ = Int(try reader.readUInt8())
        
        let payloadLength = Int(try reader.readUInt8()) - 1
        let hasID = (opcode & Self.idLengthPresent) != 0
        
        let headerLength = hasID ? Int(try reader.readUInt8()) : 0
        _ = try reader.readData(count: 3)
        header = hasID ? try reader.readData(count: headerLength) : nil
        
        let checksum = Int(try reader.readUInt8())
        self.checksum = checksum
        sequence = checksum & 0x0F
        
        let actualLength = min(reader.remainingCount, payloadLength)
        content = try reader.readData(count: actualLength)
    }
    
    func encoded() -> Data {
        let headerLength = header?.count ?? 0
        let hasHeader = headerLength > 0
        
        var writer = ByteWriter()
        
        writer.writeUInt8(
            Self.messageBegin |
            Self.messageEnd |
            Self.shortRecord |
            (hasHeader ? Self.idLengthPresent : 0) |
            Self.wellKnown
        )
        
        writer.writeUInt8(3)
        writer.writeUInt8(content.count + 1)
        
        if hasHeader {
            writer.writeUInt8(headerLength)
        }
        
        writer.writeData(Data("PHD".utf8))
        writer.writeUInt8((sequence & 0x0F) | 0x80 | checksum)
        writer.writeData(content)
        return writer.data
    }
}
