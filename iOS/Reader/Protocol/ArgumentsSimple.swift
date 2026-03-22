import Foundation

struct ArgumentsSimple {
    let handle: Int
    let size: Int
    let size2: Int
    
    init(handle: Int, size: Int = 0, size2: Int = 0) {
        self.handle = handle
        self.size = size
        self.size2 = size2
    }
    
    func encoded() -> Data {
        var writer = ByteWriter()
        writer.writeUInt16(handle)
        writer.writeUInt16(size)
        writer.writeUInt16(size2)
        return writer.data
    }
}
