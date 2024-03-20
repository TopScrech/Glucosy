import WidgetKit
import SwiftUI

struct LockscreenProvider: TimelineProvider {
    let userDefaults = UserDefaults(suiteName: "group.dev.topscrech.Health-Point")!
    
    var date: Date {
        let storedDate = userDefaults.double(forKey: "widgetDate")
        
        if storedDate != 0 {
            return Date(timeIntervalSinceReferenceDate: storedDate)
        } else {
            return Date(timeIntervalSinceReferenceDate: -3600)
        }
    }
    
    var glucose: String {
        userDefaults.string(forKey: "currentGlucose") ?? "-"
    }
    
    func placeholder(in context: Context) -> GlucoseEntry {
        GlucoseEntry(glucose, measureDate: date, date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (GlucoseEntry) -> ()) {
        let entry = GlucoseEntry(glucose, measureDate: date, date: Date())
        
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        
        let entryDate = Calendar.current.date(byAdding: .minute, value: 10, to: currentDate)!
        let entry = GlucoseEntry(glucose, measureDate: date, date: entryDate)
        
        let timeline = Timeline(
            entries: [entry, entry],
            policy: .atEnd
        )
        
        completion(timeline)
    }
}

struct GlucoseEntry: TimelineEntry {
    let glucose: String
    let measureDate: Date
    let date: Date
    
    init(_ glucose: String, measureDate: Date, date: Date) {
        self.glucose = glucose
        self.measureDate = measureDate
        self.date = date
    }
}

struct LockScreenWidgetEntryView: View {
    var entry: LockscreenProvider.Entry
    
    var body: some View {
        VStack(spacing: 0) {
            Text(entry.measureDate, format: .dateTime.hour().minute())
                .footnote()
                .foregroundStyle(.secondary)
            
            Text(entry.glucose)
                .fontWeight(.heavy)
                .fontSize(50)
                .scaledToFit()
                .minimumScaleFactor(0.01)
                .lineLimit(1)
                .widgetAccentable()
            
            Text("mmol/L")
                .footnote()
                .foregroundStyle(.secondary)
        }
        .containerBackground(.clear, for: .widget)
    }
}

struct SimpleWidget: Widget {
    let kind = "SimpleWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LockscreenProvider()) { entry in
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
        "16.4",
        measureDate: Date(timeIntervalSinceReferenceDate: -3600),
        date: Date()
    )
}
