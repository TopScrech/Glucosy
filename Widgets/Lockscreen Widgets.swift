import WidgetKit
import SwiftUI

struct LockscreenProvider: TimelineProvider {
    func placeholder(in context: Context) -> DateEntry {
        DateEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DateEntry) -> ()) {
        let entry = DateEntry(date: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let timeline = Timeline(entries: [DateEntry(date: Date())], policy: .never)
        completion(timeline)
    }
}

struct DateEntry: TimelineEntry {
    let date: Date
}

struct LockScreenWidgetEntryView: View {
    var entry: LockscreenProvider.Entry
    
    var body: some View {
        Text("100")
            .widgetAccentable()
            .containerBackground(.clear, for: .widget)
        
        Text("mmol/L")
            .scaledToFit()
//            .fontSize(10)
    }
}

struct SimpleWidget: Widget {
    let kind: String = "SimpleWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LockscreenProvider()) { entry in
            LockScreenWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Lock Screen Widget")
        .description("Shows a simple lock message")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .accessoryCircular) {
    SimpleWidget()
    //    SimpleWidget(entry: DateEntry(date: Date()))
    //        .previewContext(WidgetPreviewContext(family: .systemSmall))
} timeline: {
    DateEntry(date: Date())
}
