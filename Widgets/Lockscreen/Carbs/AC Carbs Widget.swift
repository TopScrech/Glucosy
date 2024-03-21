import SwiftUI
import WidgetKit

struct ACCarbsWidgetView: View {
    var entry: ACCarbsProvider.Entry
    
    init(_ entry: ACCarbsProvider.Entry) {
        self.entry = entry
    }
    
    private var deepLink: URL? {
        URL(string: entry.configuration.action.rawValue)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if entry.configuration.showDate {
                Text(entry.date, format: .dateTime.day().month())
                    .footnote()
                    .foregroundStyle(.tertiary)
            }
            
            Text(entry.data)
                .fontWeight(.heavy)
                .fontSize(100)
                .scaledToFit()
                .minimumScaleFactor(0.01)
                .lineLimit(1)
                .widgetAccentable()
            
            if entry.configuration.showUnit {
                Text("grams")
                    .footnote()
                    .foregroundStyle(.secondary)
            }
        }
        .containerBackground(.clear, for: .widget)
        .widgetURL(URL(string: deepLink))
    }
}

struct ACCarbsWidget: Widget {
    let kind = "Carbs Widget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ACCarbsConfiguration.self,
            provider: ACCarbsProvider()
        ) { entry in
            ACCarbsWidgetView(entry)
        }
        .configurationDisplayName("Lock Screen Widget")
        .description("Shows a simple lock message")
        .supportedFamilies([.accessoryCircular])
    }
}

#Preview(as: .accessoryCircular) {
    ACCarbsWidget()
} timeline: {
    CarbsEntry(
        data: 16,
        date: Date(),
        configuration: ACCarbsConfiguration()
    )
}
