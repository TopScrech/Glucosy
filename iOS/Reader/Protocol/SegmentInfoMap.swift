import Foundation

struct SegmentInfoMap {
    let bits: Int
    let count: Int
    let length: Int
    let items: [SegmentEntry]
    
    init(reader: inout ByteReader) throws {
        bits = Int(try reader.readUInt16())
        count = Int(try reader.readUInt16())
        length = Int(try reader.readUInt16())
        
        var items: [SegmentEntry] = []
        for _ in 0 ..< count {
            items.append(try SegmentEntry(reader: &reader))
        }
        
        self.items = items
    }
}
