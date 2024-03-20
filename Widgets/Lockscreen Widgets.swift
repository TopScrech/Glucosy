import WidgetKit
import SwiftUI

struct LockscreenProvider: TimelineProvider {
    let userDefaults = UserDefaults(suiteName: "group.dev.topscrech.Health-Point")
    
    func placeholder(in context: Context) -> GlucoseEntry {
        let glucose = userDefaults?.string(forKey: "currentGlucose") ?? "-"
        
        return GlucoseEntry(glucose, date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (GlucoseEntry) -> ()) {
        let glucose = userDefaults?.string(forKey: "currentGlucose") ?? "-"
        
        let entry = GlucoseEntry(glucose, date: Date())
        
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let glucose = userDefaults?.string(forKey: "currentGlucose") ?? "-"
        
        var entries: [GlucoseEntry] = []
        let currentDate = Date()
        
        for hourOffset in 0..<5 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: hourOffset, to: currentDate)!
            let entry = GlucoseEntry(glucose, date: entryDate)
            entries.append(entry)
        }
        
        let timeline = Timeline(
            entries: [GlucoseEntry(glucose, date: Date())],
            policy: .atEnd
        )
        
        completion(timeline)
    }
}

struct GlucoseEntry: TimelineEntry {
    let glucose: String
    let date: Date
    
    init(_ glucose: String, date: Date) {
        self.glucose = glucose
        self.date = date
    }
}

struct LockScreenWidgetEntryView: View {
    var entry: LockscreenProvider.Entry
    
    var body: some View {
        VStack(spacing: 0) {
            Text(entry.date, format: .dateTime.hour().minute())
                .footnote()
                .foregroundStyle(.tertiary)
            
            Text(entry.glucose)
                .largeTitle()
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
    GlucoseEntry("16.4", date: Date())
}
