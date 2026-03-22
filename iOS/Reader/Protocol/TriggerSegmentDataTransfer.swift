struct TriggerSegmentDataTransfer {
    let segmentID: Int
    let responseCode: Int
    
    init(reader: inout ByteReader) throws {
        segmentID = Int(try reader.readUInt16())
        responseCode = Int(try reader.readUInt16())
    }
    
    var isOkay: Bool {
        segmentID != 0 && responseCode == 0
    }
}
