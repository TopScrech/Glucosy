import Foundation

final class ReaderLogStore {
    let fileURL = URL.documentsDirectory.appending(path: "novopen-reader-last-log.txt")
    
    func reset() {
        try? Data().write(to: fileURL, options: .atomic)
    }
    
    func append(_ line: String) {
        let data = Data("\(line)\n".utf8)
        
        if let handle = try? FileHandle(forWritingTo: fileURL) {
            defer {
                try? handle.close()
            }
            
            do {
                try handle.seekToEnd()
                try handle.write(contentsOf: data)
                return
            } catch {
                
            }
        }
        
        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            
        }
    }
    
    func load() -> String {
        guard
            let data = try? Data(contentsOf: fileURL),
            let text = String(data: data, encoding: .utf8)
        else {
            return ""
        }
        
        return text
    }
}
