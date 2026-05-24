import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Weight"
    static let description: IntentDescription = "Shows your recent weight entries"
}
