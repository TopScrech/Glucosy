import Foundation

enum Utils {
    static func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        
        return formatter.string(from: date)
    }
    
    static func formatNumber(_ number: Double) -> String {
        if number.truncatingRemainder(dividingBy: 1) == 0 {
            String(format: "%.0f", number)
        } else {
            String(number)
        }
    }
}
