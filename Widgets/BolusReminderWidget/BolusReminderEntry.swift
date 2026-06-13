import WidgetKit

struct BasalReminderEntry: TimelineEntry {
    let date: Date
    let basalCount: Int
    let isSkippedToday: Bool
    let errorDescription: String?
}
