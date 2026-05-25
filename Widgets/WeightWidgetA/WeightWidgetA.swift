import ScrechKit
import WidgetKit

struct WeightWidgetA: Widget {
    private let kind = "Weight Widget A"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) {
            WeightWidgetAContent($0)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Body Weight A")
        .description("Shows a graph of your last 10 weight entries")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemMedium) {
    WeightWidgetA()
} timeline: {
    SimpleEntry(date: .now, weightEntries: Provider.previewEntries, errorDescription: nil)
}
