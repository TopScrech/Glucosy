import Foundation

struct EventRequest {
    let handle: Int
    let currentTime: Int
    let type: Int
    let data: Data
    
    func encoded() -> Data {
        var writer = ByteWriter()
        writer.writeUInt16(handle)
        writer.writeInt32(currentTime)
        writer.writeUInt16(type)
        writer.writeUInt16(data.count)
        writer.writeData(data)
        return writer.data
    }
}
