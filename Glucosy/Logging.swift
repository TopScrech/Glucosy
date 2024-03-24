import Foundation

@Observable
final class Log {
    var entries: [LogEntry]
    var labels: Set<String>
    
    init(_ text: String = "Log \(Date().local)\n") {
        entries = [LogEntry(message: text)]
        labels = []
    }
}

/// https://github.com/apple/swift-log/blob/main/Sources/Logging/Logging.swift
enum LogLevel: UInt8, Codable, CaseIterable {
    case trace,
         debug,
         info,
         notice,
         warning,
         error,
         critical
}

struct LogEntry: Identifiable {
    let id = UUID()
    let message: String
    let time: Date
    var label: String
    var level: LogLevel
    
    init(message: String, level: LogLevel = .info, label: String = "") {
        var label = label
        self.message = message
        self.level = level
        self.time = Date()
        
        if label.isEmpty {
            label = String(message[message.startIndex ..< (message.firstIndex(of: ":") ?? message.startIndex)])
            label = !label.contains(" ") ? label : ""
        }
        
        self.label = label
    }
}
