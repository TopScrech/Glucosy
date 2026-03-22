import Foundation

struct ReaderLogEntry: Identifiable {
    let id = UUID()
    let timestamp = Date()
    let message: String
    
    var formattedLine: String {
        "\(timestamp.formatted(.iso8601.time(includingFractionalSeconds: true))) \(message)"
    }
}
