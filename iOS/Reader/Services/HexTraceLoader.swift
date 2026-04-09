import Foundation

struct HexTraceLoader {
    func loadResponses(from resourceName: String, in bundle: Bundle) throws -> [Data] {
        guard let url = bundle.url(forResource: resourceName, withExtension: "txt") else {
            throw NovoPenError.missingSampleTrace
        }
        
        let contents = try String(contentsOf: url, encoding: .utf8)
        return parse(contents)
    }
    
    private func parse(_ contents: String) -> [Data] {
        var packets: [Data] = []
        var current = Data()
        
        for line in contents.components(separatedBy: .newlines) {
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                if !current.isEmpty {
                    packets.append(current)
                    current = Data()
                }
                
                continue
            }
            
            let parts = line.split(whereSeparator: \.isWhitespace)
            
            for part in parts.dropFirst() {
                guard part.count == 2, part.allSatisfy(\.isHexDigit) else {
                    break
                }
                
                current.append(UInt8(part, radix: 16) ?? 0)
            }
        }
        
        if !current.isEmpty {
            packets.append(current)
        }
        
        return packets
    }
}
