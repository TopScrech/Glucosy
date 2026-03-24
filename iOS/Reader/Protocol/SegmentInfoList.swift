import Foundation

struct SegmentInfoList {
    let items: [SegmentInfo]
    
    init(reader: inout ByteReader) throws {
        let count = Int(try reader.readUInt16())
        _ = Int(try reader.readUInt16())
        
        var items: [SegmentInfo] = []
        
        for _ in 0 ..< count {
            items.append(try SegmentInfo(reader: &reader))
        }
        
        self.items = items
    }
}
