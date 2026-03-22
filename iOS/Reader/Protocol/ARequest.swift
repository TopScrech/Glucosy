import Foundation

struct ARequest {
    let version: Int
    let elements: Int
    let apoep: ApoepElement
    
    init(reader: inout ByteReader) throws {
        version = Int(try reader.readInt32())
        elements = Int(try reader.readUInt16())
        _ = Int(try reader.readUInt16())
        
        var apoepElement: ApoepElement?
        
        for _ in 0 ..< elements {
            let protocolIdentifier = Int(try reader.readUInt16())
            let length = Int(try reader.readUInt16())
            let bytes = try reader.readData(count: length)
            
            guard protocolIdentifier == ApoepElement.protocolIdentifier else {
                continue
            }
            
            var elementReader = ByteReader(data: bytes)
            apoepElement = try ApoepElement(reader: &elementReader)
        }
        
        guard let apoepElement else {
            throw NovoPenError.malformedPacket("The pen did not return an APOEP element")
        }
        
        apoep = apoepElement
    }
}
