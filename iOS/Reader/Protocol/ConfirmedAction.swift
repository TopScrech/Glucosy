import Foundation

struct ConfirmedAction {
    static let storeHandle = 0x0100
    
    let handle: Int
    let type: Int
    let bytes: Data
    
    static func allSegmentsBytes() -> Data {
        Data([0x00, 0x01, 0x00, 0x02, 0x00, 0x00])
    }
    
    static func segmentBytes(segment: Int) -> Data {
        var writer = ByteWriter()
        writer.writeUInt16(segment)
        return writer.data
    }
    
    static func allSegments(handle: Int, type: Int) -> ConfirmedAction {
        ConfirmedAction(
            handle: handle,
            type: type,
            bytes: allSegmentsBytes()
        )
    }
    
    static func segment(handle: Int, type: Int, segment: Int) -> ConfirmedAction {
        ConfirmedAction(handle: handle, type: type, bytes: segmentBytes(segment: segment))
    }
    
    static func custom(handle: Int, type: Int, bytes: Data) -> ConfirmedAction {
        ConfirmedAction(handle: handle, type: type, bytes: bytes)
    }
    
    func encoded() -> Data {
        var writer = ByteWriter()
        writer.writeUInt16(handle)
        writer.writeUInt16(type)
        writer.writeUInt16(bytes.count)
        writer.writeData(bytes)
        return writer.data
    }
}
