import SwiftUI
import Charts
import WidgetKit
import Intents

extension Int {
    var units: String {
        UserDefaults(suiteName: "group.dev.topscrech.Health-Point")!.bool(forKey: "displayingMillimoles") ?
        String(format: "%.1f", Double(self) / 18.0182) : String(self)
    }
}

extension Double {
    var units: String {
        UserDefaults(suiteName: "group.dev.topscrech.Health-Point")!.bool(forKey: "displayingMillimoles") ?
        String(format: "%.1f", self / 18.0182) : String(format: "%.0f", self)
    }
}

struct SMChartWidgetView: View {
    var entry: ChartProvider.Entry
    
    init(_ entry: ChartProvider.Entry) {
        self.entry = entry
    }
    
    private var deepLink: URL? {
        URL(string: entry.configuration.action.rawValue)
    }
    
    var body: some View {
        VStack {
            Chart {
                ForEach(entry.glucose, id: \.self) { glucose in
                    if let value = Double(glucose.value.units) {
                        PointMark(
                            x: .value("Date", glucose.date),
                            y: value
                        )
                    }
                }
            }
        }
        .containerBackground(.ultraThinMaterial, for: .widget)
        .widgetURL(deepLink)
    }
}

struct SMChartWidget: Widget {
    let kind = "Glucose Widget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ChartConfiguration.self,
            provider: ChartProvider()
        ) { entry in
            SMChartWidgetView(entry)
        }
        .configurationDisplayName("Lock Screen Widget")
        .description("Shows a simple lock message")
        .supportedFamilies([.systemMedium])
    }
}

extension ChartConfiguration {
    fileprivate static var standard: ChartConfiguration {
        ChartConfiguration()
    }
}

//#Preview(as: .systemMedium) {
//    SMChartWidget()
//} timeline: {
//    ChartEntry(
//        date: Date(),
//        glucose: [
//            .init(value: 16, date: Date()),
//            .init(value: 16, date: Date().addingTimeInterval(50)),
//            .init(value: 16, date: Date().addingTimeInterval(1000)),
//            .init(value: 16, date: Date().addingTimeInterval(6000)),
//        ],
//        unit: "mmol/L",
//        configuration: .standard
//    )
//}
