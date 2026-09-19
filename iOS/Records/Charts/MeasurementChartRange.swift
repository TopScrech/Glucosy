import Foundation

enum MeasurementChartRange: String, CaseIterable, Identifiable {
    case day = "D", week = "W", month = "M", sixMonths = "6M", year = "Y"
    
    static let allCases: [Self] = [.week, .month, .sixMonths, .year]
    
    var id: Self {
        self
    }
    
    var axisStrideComponent: Calendar.Component {
        switch self {
        case .day: .hour
        case .week: .day
        case .month: .day
        case .sixMonths, .year: .month
        }
    }
    
    var axisStrideCount: Int {
        switch self {
        case .day: 6
        case .week: 1
        case .month: 7
        case .sixMonths: 1
        case .year: 2
        }
    }
    
    func axisLabel(for date: Date) -> String {
        switch self {
        case .day:
            date.formatted(.dateTime.hour())
            
        case .week:
            date.formatted(.dateTime.weekday(.narrow))
            
        case .month:
            date.formatted(.dateTime.day())
            
        case .sixMonths, .year:
            date.formatted(.dateTime.month(.abbreviated))
        }
    }
    
    var usesAverageAggregation: Bool {
        self != .day
    }
    
    func interval(endingAt endDate: Date = .now, calendar: Calendar = .current) -> DateInterval {
        let end = endDate
        
        switch self {
        case .day:
            return DateInterval(
                start: calendar.startOfDay(for: end),
                end: end
            )
            
        case .week:
            let start = calendar.date(
                byAdding: .day,
                value: -6,
                to: calendar.startOfDay(for: end)
            ) ?? end
            
            return DateInterval(start: start, end: end)
            
        case .month:
            let start = calendar.date(
                byAdding: .day,
                value: -29,
                to: calendar.startOfDay(for: end)
            ) ?? end
            
            return DateInterval(start: start, end: end)
            
        case .sixMonths:
            let monthStart = calendar.dateInterval(of: .month, for: end)?.start ?? end
            let start = calendar.date(byAdding: .month, value: -5, to: monthStart) ?? end
            
            return DateInterval(start: start, end: end)
            
        case .year:
            let monthStart = calendar.dateInterval(of: .month, for: end)?.start ?? end
            let start = calendar.date(byAdding: .month, value: -11, to: monthStart) ?? end
            
            return DateInterval(start: start, end: end)
        }
    }
    
    func bucketStart(for date: Date, calendar: Calendar = .current) -> Date {
        switch self {
        case .day:
            let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
            return calendar.date(from: components) ?? date
            
        case .week, .month:
            return calendar.startOfDay(for: date)
            
        case .sixMonths:
            return calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
            
        case .year:
            return calendar.dateInterval(of: .month, for: date)?.start ?? date
        }
    }
    
    func dayCount(
        endingAt endDate: Date = .now,
        calendar: Calendar = .current
    ) -> Int {
        let interval = interval(endingAt: endDate, calendar: calendar)
        let startOfFirstDay = calendar.startOfDay(for: interval.start)
        let startOfLastDay = calendar.startOfDay(for: interval.end)
        let dayDifference = calendar.dateComponents([.day], from: startOfFirstDay, to: startOfLastDay).day ?? 0
        
        return dayDifference + 1
    }
}
