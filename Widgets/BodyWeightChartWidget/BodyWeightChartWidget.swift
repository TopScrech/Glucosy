import ScrechKit
import WidgetKit

struct BodyWeightChartWidget: Widget {
    private let kind = "Glucosy_Body_Weight_Chart_Widget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) {
            BodyWeightChartWidgetView(entry: $0)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Body Weight")
        .description("Shows your recent body weight trend")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    BodyWeightChartWidget()
} timeline: {
    SimpleEntry(date: .now, weightEntries: Provider.bodyWeightChartPreviewEntries, errorDescription: nil)
}
