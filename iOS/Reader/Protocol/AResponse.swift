import Foundation

struct AResponse {
    let result: Int
    let protocolIdentifier: Int
    let apoep: ApoepElement
    
    func encoded() -> Data {
        var responseElement = apoep
        responseElement.recMode = 0
        responseElement.configID = 0
        responseElement.systemType = Int(bitPattern: UInt(ApoepElement.systemTypeManager))
        responseElement.listCount = 0
        responseElement.listLength = 0
        
        let elementData = responseElement.encoded()
        var writer = ByteWriter()
        writer.writeUInt16(result)
        writer.writeUInt16(protocolIdentifier)
        writer.writeUInt16(elementData.count)
        writer.writeData(elementData)
        return writer.data
    }
}
