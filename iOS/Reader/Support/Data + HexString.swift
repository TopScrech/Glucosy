import Foundation

extension Data {
    var hexString: String {
        map(\.hexByteString).joined(separator: " ")
    }
}

extension UInt8 {
    var hexByteString: String {
        let hexadecimal = String(self, radix: 16, uppercase: true)
        return String(repeating: "0", count: Swift.max(0, 2 - hexadecimal.count)) + hexadecimal
    }
}
