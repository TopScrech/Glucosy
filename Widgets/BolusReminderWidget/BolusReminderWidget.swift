import ScrechKit
import WidgetKit

struct BasalReminderWidget: Widget {
    static let kind = BasalReminderAppStorage.widgetKind
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: BasalReminderProvider()) {
            BasalReminderWidgetContent(entry: $0)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Basal Reminder")
        .description("Reminds you to take a basal injection when none has been logged today")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    BasalReminderWidget()
} timeline: {
    BasalReminderEntry(date: .now, basalCount: 0, isSkippedToday: false, errorDescription: nil)
    BasalReminderEntry(date: .now, basalCount: 1, isSkippedToday: false, errorDescription: nil)
}
