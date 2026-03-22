import Foundation

struct DataApdu {
    static let confirmedEventReportChosen = 0x0101
    static let simpleGetChosen = 0x0103
    static let confirmedAction = 0x0107
    static let confirmedActionChosen = 0x0207
    static let segmentGetInfo = 0x0C0D
    static let segmentTriggerTransfer = 0x0C1C
    static let confirmedEventReport = 0x0201
    
    let invokeID: Int
    let choice: Int
    let payload: Data
    
    init(invokeID: Int, choice: Int, payload: Data) {
        self.invokeID = invokeID
        self.choice = choice
        self.payload = payload
    }
    
    init(reader: inout ByteReader) throws {
        _ = Int(try reader.readUInt16())
        invokeID = Int(try reader.readUInt16())
        choice = Int(try reader.readUInt16())
        let payloadLength = Int(try reader.readUInt16())
        payload = try reader.readData(count: payloadLength)
    }
    
    func encoded() -> Data {
        var writer = ByteWriter()
        writer.writeUInt16(payload.count + 6)
        writer.writeUInt16(invokeID)
        writer.writeUInt16(choice)
        writer.writeUInt16(payload.count)
        writer.writeData(payload)
        return writer.data
    }
    
    func eventReport() throws -> EventReport? {
        guard choice == Self.confirmedEventReportChosen else {
            return nil
        }
        
        var reader = ByteReader(data: payload)
        return try EventReport(reader: &reader)
    }
    
    func fullSpecification() throws -> FullSpecification? {
        guard choice == Self.simpleGetChosen || choice == 0x0203 else {
            return nil
        }
        
        var reader = ByteReader(data: payload)
        _ = Int(try reader.readUInt16())
        let count = Int(try reader.readUInt16())
        _ = Int(try reader.readUInt16())
        
        var attributes: [Attribute] = []
        for _ in 0 ..< count {
            attributes.append(try Attribute(reader: &reader))
        }
        
        return try FullSpecification(attributes: attributes)
    }
    
    func segmentInfoList() throws -> SegmentInfoList? {
        guard choice == Self.confirmedActionChosen else {
            return nil
        }
        
        var reader = ByteReader(data: payload)
        _ = Int(try reader.readUInt16())
        let actionType = Int(try reader.readUInt16())
        _ = Int(try reader.readUInt16())
        
        guard actionType == Self.segmentGetInfo else {
            return nil
        }
        
        return try SegmentInfoList(reader: &reader)
    }
    
    func triggerSegmentDataTransfer() throws -> TriggerSegmentDataTransfer? {
        guard choice == Self.confirmedActionChosen else {
            return nil
        }
        
        var reader = ByteReader(data: payload)
        _ = Int(try reader.readUInt16())
        let actionType = Int(try reader.readUInt16())
        _ = Int(try reader.readUInt16())
        
        guard actionType == Self.segmentTriggerTransfer else {
            return nil
        }
        
        return try TriggerSegmentDataTransfer(reader: &reader)
    }
}
