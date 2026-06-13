import AppIntents
import WidgetKit

struct MarkBasalReminderDoneIntent: AppIntent {
    static let title: LocalizedStringResource = "Mark Basal Done Today"
    static let description = IntentDescription("Skip the basal reminder for today")
    
    func perform() async throws -> some IntentResult {
        BasalReminderAppStorage.skipToday()
        WidgetCenter.shared.reloadTimelines(ofKind: BasalReminderAppStorage.widgetKind)
        
        return .result()
    }
}
