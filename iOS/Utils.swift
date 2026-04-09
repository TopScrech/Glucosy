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
    
    static func formatTenths(_ number: Double) -> String {
        number.formatted(.number.precision(.fractionLength(0 ... 1)))
    }
    
    static func formatTenths(_ number: Double?) -> String {
        guard let number else {
            return "-"
        }
        
        return formatTenths(number)
    }
}
