import SwiftUI
import WidgetKit
import Intents

struct ACGlucoseProvider: AppIntentTimelineProvider {
    private let userDefaults = UserDefaults(suiteName: "group.dev.topscrech.Health-Point")!
    
    private var date: Date {
        let storedDate = userDefaults.double(forKey: "widgetDate")
        return storedDate != 0 ? Date(timeIntervalSinceReferenceDate: storedDate) : Date()
    }
    
    private var glucose: String {
        userDefaults.string(forKey: "currentGlucose") ?? "-"
    }
    
    private var unit: String {
        let displayingMillimoles = userDefaults.bool(forKey: "displayingMillimoles")
        
        if displayingMillimoles {
            return "mmol/L"
        } else {
            return "mg/dL"
        }
    }
    
    // Xcode previews
    func placeholder(in context: Context) -> GlucoseEntry {
        GlucoseEntry(
            glucose: "-",
            measureDate: Date(),
            unit: unit,
            date: Date(),
            configuration: ACGlucoseConfiguration()
        )
    }
    
    // Widget gallery
    func snapshot(
        for configuration: ACGlucoseConfiguration,
        in context: Context
    ) async -> GlucoseEntry {
        GlucoseEntry(
            glucose: glucose,
            measureDate: date,
            unit: unit,
            date: Date(),
            configuration: configuration
        )
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
            unit: unit,
            date: entryDate,
            configuration: configuration
        )
        
        let timeline = Timeline(entries: [entry], policy: .after(entryDate))
        
        return timeline
    }
}

struct ACGlucoseWidgetView: View {
    var entry: ACGlucoseProvider.Entry
    
    init(_ entry: ACGlucoseProvider.Entry) {
        self.entry = entry
    }
    
    private var deepLink: URL? {
        URL(string: entry.configuration.action.rawValue)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if entry.configuration.glucoseMeasurementReminder {
                if let difference = showReminder(Date(), entry.measureDate) {
                    Image(systemName: "sensor.tag.radiowaves.forward")
                        .largeTitle()
                        .widgetAccentable()
                    
                    Text("\(difference)h ago")
                        .footnote()
                } else {
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
                        Text(entry.unit)
                            .footnote()
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .containerBackground(.clear, for: .widget)
        .widgetURL(deepLink)
    }
}

struct ACGlucoseWidget: Widget {
    let kind = "Glucose Widget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ACGlucoseConfiguration.self,
            provider: ACGlucoseProvider()
        ) { entry in
            ACGlucoseWidgetView(entry)
        }
        .configurationDisplayName("Lock Screen Widget")
        .description("Shows a simple lock message")
        .supportedFamilies([.accessoryCircular])
    }
}

extension ACGlucoseConfiguration {
    fileprivate static var preview: ACGlucoseConfiguration {
        let intent = ACGlucoseConfiguration()
        
        return intent
    }
}

#Preview(as: .accessoryCircular) {
    ACGlucoseWidget()
} timeline: {
    GlucoseEntry(
        glucose: "16.4",
        measureDate: Date().addingTimeInterval(-7200),
        unit: "mmol/L",
        date: Date(),
        configuration: .preview
    )
}
