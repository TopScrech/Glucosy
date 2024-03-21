import SwiftUI
import WidgetKit
import Intents

struct LockscreenProvider: AppIntentTimelineProvider {
    private let userDefaults = UserDefaults(suiteName: "group.dev.topscrech.Health-Point")!
    
    private var date: Date {
        let storedDate = userDefaults.double(forKey: "widgetDate")
        return storedDate != 0 ? Date(timeIntervalSinceReferenceDate: storedDate) : Date()
    }
    
    private var glucose: String {
        userDefaults.string(forKey: "currentGlucose") ?? "-"
    }
    
    // Xcode previews
    func placeholder(in context: Context) -> GlucoseEntry {
        GlucoseEntry(glucose: "-", measureDate: Date(), date: Date(), configuration: ACGlucoseConfiguration())
    }
    
    // Widget gallery
    func snapshot(
        for configuration: ACGlucoseConfiguration,
        in context: Context
    ) async -> GlucoseEntry {
        GlucoseEntry(glucose: glucose, measureDate: date, date: Date(), configuration: configuration)
    }
    
    // Timeline generation with user configuration
    func timeline(
        for configuration: ACGlucoseConfiguration,
        in context: Context
    ) async -> Timeline<GlucoseEntry> {
        let currentDate = Date()
        
        let entryDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        
        let entry = GlucoseEntry(
            glucose: glucose,
            measureDate: date, 
            date: entryDate,
            configuration: configuration
        )
        
        let timeline = Timeline(entries: [entry], policy: .after(entryDate))
        
        return timeline
    }
}

struct GlucoseEntry: TimelineEntry {
    let glucose: String
    let measureDate: Date
    let date: Date
    let configuration: ACGlucoseConfiguration
}

struct LockScreenWidgetEntryView: View {
    var entry: LockscreenProvider.Entry
    
    init(_ entry: LockscreenProvider.Entry) {
        self.entry = entry
    }
    
    private var deepLink: String {
        entry.configuration.startNfc ? "action/scan" : ""
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if entry.configuration.showMeasureTime {
                Text(entry.measureDate, format: .dateTime.hour().minute())
                    .footnote()
                    .foregroundStyle(.tertiary)
            }
            
            Text(entry.glucose)
                .fontWeight(.heavy)
                .fontSize(100)
                .scaledToFit()
                .minimumScaleFactor(0.01)
                .lineLimit(1)
                .widgetAccentable()
            
            if entry.configuration.showUnit {
                Text("mmol/L")
                    .footnote()
                    .foregroundStyle(.secondary)
            }
        }
        .containerBackground(.clear, for: .widget)
        .widgetURL(URL(string: deepLink))
    }
}

struct ACGlucoseWidget: Widget {
    let kind = "Glucose Widget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ACGlucoseConfiguration.self,
            provider: LockscreenProvider()
        ) { entry in
            LockScreenWidgetEntryView(entry)
        }
        .configurationDisplayName("Lock Screen Widget")
        .description("Shows a simple lock message")
        .supportedFamilies([.accessoryCircular])
    }
}

#Preview(as: .accessoryCircular) {
    ACGlucoseWidget()
} timeline: {
    GlucoseEntry(
        glucose: "16.4",
        measureDate: Date(timeIntervalSinceReferenceDate: -3600),
        date: Date(),
        configuration: ACGlucoseConfiguration()
    )
}
