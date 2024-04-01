import SwiftUI
import WidgetKit
import Intents

struct SSGlucoseWidgetView: View {
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
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .widgetAccentable()
                    
                    Spacer()
                    
                    Text("\(difference)h ago")
                        .semibold()
                        .rounded()
                        .fontSize(20)
                        .scaledToFit()
                } else {
                    if entry.configuration.showMeasureTime {
                        HStack(spacing: 4) {
                            Image(.icon)
                                .resizable()
                                .frame(width: 25, height: 25)
                                .clipShape(.rect(cornerRadius: 8))
                            
                            Spacer()
                            
                            Text(entry.measureDate, format: .dateTime.hour().minute())
                                .semibold()
                        }
                        .foregroundStyle(.secondary)
                        .frame(width: .infinity, alignment: .leading)
                    }
                    
                    Spacer()
                    
                    Text(entry.glucose)
                        .rounded()
                        .fontWeight(.heavy)
                        .fontSize(100)
                        .scaledToFit()
                        .minimumScaleFactor(0.01)
                        .lineLimit(1)
                        .widgetAccentable()
                    
                    if entry.configuration.showUnit {
                        Spacer()
                        
                        HStack {
                            Text("5m ago")
                                .semibold()
                            
                            Spacer()
                            
                            Text(entry.unit)
                                .semibold()
                                .foregroundStyle(.secondary)
                        }
                        .scaledToFit()
                        .minimumScaleFactor(0.01)
                    } else {
                        Spacer()
                    }
                }
            }
        }
        .containerBackground(.ultraThinMaterial, for: .widget)
        .widgetURL(deepLink)
    }
}

struct SSGlucoseWidget: Widget {
    let kind = "Glucose Widget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ACGlucoseConfiguration.self,
            provider: ACGlucoseProvider()
        ) { entry in
            SSGlucoseWidgetView(entry)
        }
        .configurationDisplayName("Lock Screen Widget")
        .description("Shows a simple lock message")
        .supportedFamilies([.systemSmall])
    }
}

extension ACGlucoseConfiguration {
    fileprivate static var hiddenTime: ACGlucoseConfiguration {
        let configuration = ACGlucoseConfiguration()
        
        configuration.showMeasureTime = false
        
        return configuration
    }
    
    fileprivate static var hiddenUnit: ACGlucoseConfiguration {
        let configuration = ACGlucoseConfiguration()
        
        configuration.showUnit = false
        
        return configuration
    }
    
    fileprivate static var everythingHidden: ACGlucoseConfiguration {
        let configuration = ACGlucoseConfiguration()
        
        configuration.showUnit = false
        configuration.showMeasureTime = false
        
        return configuration
    }
    
    fileprivate static var standard: ACGlucoseConfiguration {
        ACGlucoseConfiguration()
    }
}

#Preview(as: .systemSmall) {
    SSGlucoseWidget()
} timeline: {
    GlucoseEntry(
        glucose: "16.4",
        measureDate: Date().addingTimeInterval(-7200),
        unit: "mmol/L",
        date: Date(),
        configuration: .standard
    )
    
    GlucoseEntry(
        glucose: "16.4",
        measureDate: Date(),
        unit: "mmol/L",
        date: Date(),
        configuration: .standard
    )
    
    GlucoseEntry(
        glucose: "16.4",
        measureDate: Date(),
        unit: "mmol/L",
        date: Date(),
        configuration: .hiddenUnit
    )
    
    GlucoseEntry(
        glucose: "16.4",
        measureDate: Date(),
        unit: "mmol/L",
        date: Date(),
        configuration: .hiddenTime
    )
    
    GlucoseEntry(
        glucose: "16.4",
        measureDate: Date(),
        unit: "mmol/L",
        date: Date(),
        configuration: .everythingHidden
    )
}
