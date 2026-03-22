import Foundation

struct SegmentEntry {
    let classID: Int
    let metricType: Int
    let objectType: Int
    let handle: Int
    let attributeMapCount: Int
    let data: Data
    
    init(reader: inout ByteReader) throws {
        classID = Int(try reader.readUInt16())
        metricType = Int(try reader.readUInt16())
        objectType = Int(try reader.readUInt16())
        handle = Int(try reader.readUInt16())
        attributeMapCount = Int(try reader.readUInt16())
        let length = Int(try reader.readUInt16())
        data = try reader.readData(count: length)
    }
}
