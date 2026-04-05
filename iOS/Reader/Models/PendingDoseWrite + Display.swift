import Foundation

extension PendingDoseWrite {
    var timestampLabel: String {
        let timestamp = dose.timestamp
        let time = timestamp.formatted(.dateTime.hour().minute())
        
        if Calendar.current.isDateInToday(timestamp) {
            return "\(String(localized: "Today")), \(time)"
        }
        
        if Calendar.current.isDateInYesterday(timestamp) {
            return "\(String(localized: "Yesterday")), \(time)"
        }
        
        return timestamp.formatted(.dateTime.day().month().hour().minute())
    }
}
