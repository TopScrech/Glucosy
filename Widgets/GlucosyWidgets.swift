import ScrechKit
import WidgetKit

struct GlucosyWidgets: Widget {
    private let kind = "Glucosy_Widgets"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) {
            WeightWidgetEntryView($0)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Weight")
        .description("Shows a graph of your last 10 weight entries")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemMedium) {
    GlucosyWidgets()
} timeline: {
    SimpleEntry(date: .now, weightEntries: Provider.previewEntries, errorDescription: nil)
}
