import ScrechKit
import WidgetKit

struct WeightWidgetB: Widget {
    private let kind = "Weight Widget B"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) {
            WeightWidgetBContent(entry: $0)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Body Weight B")
        .description("Shows a graph of your last 10 weight entries")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    WeightWidgetB()
} timeline: {
    SimpleEntry(date: .now, weightEntries: Provider.bodyWeightChartPreviewEntries, errorDescription: nil)
}

#Preview(as: .systemMedium) {
    WeightWidgetB()
} timeline: {
    SimpleEntry(date: .now, weightEntries: Provider.bodyWeightChartPreviewEntries, errorDescription: nil)
}
