import WidgetKit
import SwiftUI
import Intents

struct LockscreenProvider: AppIntentTimelineProvider {
    // Xcode previews
    func placeholder(in context: Context) -> GlucoseEntry {
        GlucoseEntry(glucose: "-", measureDate: Date(), date: Date(), configuration: LockScreenConfiguration())
    }
    
    // Widget gallery
    func snapshot(
        for configuration: LockScreenConfiguration,
        in context: Context
    ) async -> GlucoseEntry {
        GlucoseEntry(glucose: glucose, measureDate: date, date: Date(), configuration: configuration)
    }
    
    // Timeline generation with user configuration
    func timeline(
        for configuration: LockScreenConfiguration,
        in context: Context
    ) async -> Timeline<GlucoseEntry> {
        let currentDate = Date()
        
        let entryDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let entry = GlucoseEntry(glucose: glucose, measureDate: date, date: entryDate, configuration: configuration)
        
        let timeline = Timeline(entries: [entry], policy: .after(entryDate))
        return timeline
    }
    
    private let userDefaults = UserDefaults(suiteName: "group.dev.topscrech.Health-Point")!
    
    private var date: Date {
        let storedDate = userDefaults.double(forKey: "widgetDate")
        return storedDate != 0 ? Date(timeIntervalSinceReferenceDate: storedDate) : Date()
    }
    
    private var glucose: String {
        userDefaults.string(forKey: "currentGlucose") ?? "-"
    }
}

struct GlucoseEntry: TimelineEntry {
    let glucose: String
    let measureDate: Date
    let date: Date
    let configuration: LockScreenConfiguration
}

struct LockScreenWidgetEntryView: View {
    var entry: LockscreenProvider.Entry
    
    var body: some View {
        VStack(spacing: 0) {
            if entry.configuration.showMeasureTime {
                Text(entry.measureDate, format: .dateTime.hour().minute())
                    .footnote()
                    .foregroundStyle(.secondary)
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
    }
}

struct SimpleWidget: Widget {
    let kind = "SimpleWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: LockScreenConfiguration.self,
            provider: LockscreenProvider()
        ) { entry in
            LockScreenWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Lock Screen Widget")
        .description("Shows a simple lock message")
        .supportedFamilies([.accessoryCircular])
    }
}

#Preview(as: .accessoryCircular) {
    SimpleWidget()
} timeline: {
    GlucoseEntry(
        glucose: "16.4",
        measureDate: Date(timeIntervalSinceReferenceDate: -3600),
        date: Date(),
        configuration: LockScreenConfiguration()
    )
}
