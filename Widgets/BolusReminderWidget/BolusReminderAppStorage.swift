import Foundation

enum BasalReminderAppStorage {
    nonisolated static let skippedDateKey = "basal_reminder_skipped_date"
    nonisolated static let suiteName = "group.dev.topscrech.Glucosy"
    nonisolated static let widgetKind = "Basal Reminder Widget"
    
    nonisolated static var userDefaults: UserDefaults {
        UserDefaults(suiteName: suiteName) ?? .standard
    }
    
    nonisolated static func isSkippedToday(date: Date = .now) -> Bool {
        let skippedTimestamp = userDefaults.double(forKey: skippedDateKey)
        
        guard skippedTimestamp > 0 else {
            return false
        }
        
        return Calendar.current.isDate(
            Date(timeIntervalSince1970: skippedTimestamp),
            inSameDayAs: date
        )
    }
    
    nonisolated static func skipToday(date: Date = .now) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        userDefaults.set(startOfDay.timeIntervalSince1970, forKey: skippedDateKey)
    }
}
