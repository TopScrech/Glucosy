import Foundation

struct FullSpecification {
    let specification: Specification
    let relativeTime: Int
    let model: [String]
    
    init(attributes: [Attribute]) throws {
        var specification = Specification()
        var relativeTime = 0
        var model: [String] = []
        
        for attribute in attributes {
            switch attribute.type {
            case Attribute.productSpecificationID:
                var reader = ByteReader(data: attribute.data)
                specification = try Specification(reader: &reader)
                
            case Attribute.relativeTime:
                var reader = ByteReader(data: attribute.data)
                relativeTime = Int(try reader.readInt32())
                
            case Attribute.modelID:
                var reader = ByteReader(data: attribute.data)
                
                while reader.hasRemaining {
                    model.append(try reader.readIndexedString())
                }
                
            default:
                break
            }
        }
        
        self.specification = specification
        self.relativeTime = relativeTime
        self.model = model
    }
}
