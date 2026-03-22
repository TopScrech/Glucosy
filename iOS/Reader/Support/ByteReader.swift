import Foundation

struct ByteReader {
    private let data: Data
    private var offset = 0

    init(data: Data) {
        self.data = Data(data)
    }

    var hasRemaining: Bool {
        offset < data.count
    }

    var remainingCount: Int {
        data.count - offset
    }

    mutating func readUInt8() throws -> UInt8 {
        guard offset < data.count else {
            throw NovoPenError.malformedPacket("Unexpected end of data")
        }

        defer { offset += 1 }
        return data[offset]
    }

    mutating func readUInt16() throws -> UInt16 {
        let first = UInt16(try readUInt8())
        let second = UInt16(try readUInt8())
        return (first << 8) | second
    }

    mutating func readInt32() throws -> Int32 {
        let first = UInt32(try readUInt8())
        let second = UInt32(try readUInt8())
        let third = UInt32(try readUInt8())
        let fourth = UInt32(try readUInt8())
        let value = (first << 24) | (second << 16) | (third << 8) | fourth
        return Int32(bitPattern: value)
    }

    mutating func readData(count: Int) throws -> Data {
        guard count >= 0, offset + count <= data.count else {
            throw NovoPenError.malformedPacket("Unexpected end of data")
        }

        defer { offset += count }
        return Data(data[offset ..< offset + count])
    }

    mutating func readIndexedString() throws -> String {
        let length = Int(try readUInt16())
        let stringData = try readData(count: length)
        return String(decoding: stringData, as: UTF8.self).replacing("\0", with: "")
    }
}
