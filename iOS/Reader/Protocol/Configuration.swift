import Foundation

struct Configuration {
    let id: Int
    let handle: Int
    let numberOfSegments: Int
    let totalEntries: Int
    let unitCode: Int
    let totalStorage: Int
    let objectHandles: [Int]
    let attributes: [Attribute]
    
    var candidateActionHandles: [Int] {
        var handles: [Int] = []
        
        for candidate in [ConfirmedAction.storeHandle, handle] + objectHandles {
            guard candidate >= 0 else {
                continue
            }
            
            if !handles.contains(candidate) {
                handles.append(candidate)
            }
        }
        
        return handles
    }
    
    init(reader: inout ByteReader) throws {
        id = Int(try reader.readUInt16())
        let count = Int(try reader.readUInt16())
        _ = Int(try reader.readUInt16())
        
        var numberOfSegments = -1
        var totalEntries = -1
        var unitCode = -1
        var totalStorage = -1
        var objectHandles: [Int] = []
        var attributes: [Attribute] = []
        var primaryHandle = 0
        
        for _ in 0 ..< count {
            _ = Int(try reader.readUInt16())
            let handle = Int(try reader.readUInt16())
            let attributeCount = Int(try reader.readUInt16())
            _ = Int(try reader.readUInt16())
            
            if primaryHandle == 0 {
                primaryHandle = handle
            }
            
            objectHandles.append(handle)
            
            for _ in 0 ..< attributeCount {
                let attribute = try Attribute(reader: &reader)
                
                switch attribute.type {
                case Attribute.numberOfSegments:
                    numberOfSegments = attribute.value
                
                case Attribute.metricStoreUsageCount:
                    totalEntries = attribute.value
                
                case Attribute.unitCode:
                    unitCode = attribute.value
                
                case Attribute.metricStoreCapacityCount:
                    totalStorage = attribute.value
                
                default:
                    break
                }
                
                attributes.append(attribute)
            }
        }
        
        self.handle = primaryHandle
        self.numberOfSegments = numberOfSegments
        self.totalEntries = totalEntries
        self.unitCode = unitCode
        self.totalStorage = totalStorage
        self.objectHandles = objectHandles
        self.attributes = attributes
    }
}
