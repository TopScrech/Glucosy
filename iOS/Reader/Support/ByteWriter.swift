import Foundation

struct ByteWriter {
    private(set) var data = Data()

    mutating func writeUInt8(_ value: Int) {
        data.append(UInt8(value & 0xFF))
    }

    mutating func writeUInt16(_ value: Int) {
        data.append(UInt8((value >> 8) & 0xFF))
        data.append(UInt8(value & 0xFF))
    }

    mutating func writeInt32(_ value: Int) {
        data.append(UInt8((value >> 24) & 0xFF))
        data.append(UInt8((value >> 16) & 0xFF))
        data.append(UInt8((value >> 8) & 0xFF))
        data.append(UInt8(value & 0xFF))
    }

    mutating func writeData(_ value: Data) {
        data.append(value)
    }
}
