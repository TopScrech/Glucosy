import Foundation

struct SegmentInfo {
    let instanceNumber: Int
    let usage: Int
    let items: [Attribute]
    let segmentInfoMap: SegmentInfoMap?
    
    init(
        instanceNumber: Int,
        usage: Int,
        items: [Attribute],
        segmentInfoMap: SegmentInfoMap?
    ) {
        self.instanceNumber = instanceNumber
        self.usage = usage
        self.items = items
        self.segmentInfoMap = segmentInfoMap
    }
    
    init(reader: inout ByteReader) throws {
        instanceNumber = Int(try reader.readUInt16())
        let count = Int(try reader.readUInt16())
        _ = Int(try reader.readUInt16())
        
        var usage = -1
        var segmentInfoMap: SegmentInfoMap?
        var items: [Attribute] = []
        
        for _ in 0 ..< count {
            let attribute = try Attribute(reader: &reader)
            
            switch attribute.type {
            case Attribute.segmentMap:
                var attributeReader = ByteReader(data: attribute.data)
                segmentInfoMap = try SegmentInfoMap(reader: &attributeReader)
            
            case Attribute.segmentUsageCount:
                usage = attribute.value
            
            default:
                break
            }
            
            items.append(attribute)
        }
        
        self.usage = usage
        self.segmentInfoMap = segmentInfoMap
        self.items = items
    }
}
