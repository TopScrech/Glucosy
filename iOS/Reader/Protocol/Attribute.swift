import Foundation

struct Attribute {
    static let modelID = 2344
    static let productSpecificationID = 2349
    static let metricStoreCapacityCount = 2369
    static let metricStoreUsageCount = 2372
    static let numberOfSegments = 2385
    static let segmentUsageCount = 2427
    static let relativeTime = 2447
    static let unitCode = 2454
    static let attributeValueMap = 2645
    static let segmentMap = 2638
    
    let type: Int
    let data: Data
    let value: Int
    
    init(reader: inout ByteReader) throws {
        type = Int(try reader.readUInt16())
        let length = Int(try reader.readUInt16())
        data = try reader.readData(count: length)
        
        switch data.count {
        case 2:
            var dataReader = ByteReader(data: data)
            value = Int(try dataReader.readUInt16())
        case 4:
            var dataReader = ByteReader(data: data)
            value = Int(try dataReader.readInt32())
        default:
            value = -1
        }
    }
}
