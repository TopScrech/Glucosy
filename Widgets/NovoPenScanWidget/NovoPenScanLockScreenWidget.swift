import SwiftUI
import WidgetKit

@available(iOS 18.0, *)
struct NovoPenScanLockScreenWidget: Widget {
    static let kind = "dev.topscrech.Glucosy.NovoPenScanLockScreen"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: NovoPenScanProvider()) {
            NovoPenScanWidgetContent(entry: $0)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Scan NovoPen")
        .description("Open Glucosy and start a NovoPen NFC scan")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

@available(iOS 18.0, *)
#Preview(as: .accessoryRectangular) {
    NovoPenScanLockScreenWidget()
} timeline: {
    NovoPenScanEntry(date: .now)
}
