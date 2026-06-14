import SwiftUI
import WidgetKit

@available(iOS 18.0, *)
struct NovoPenScanControlWidget: ControlWidget {
    static let kind = "dev.topscrech.Glucosy.NovoPenScanControl"
    
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(action: OpenNovoPenScanIntent()) {
                Label("Scan NovoPen", systemImage: "wave.3.right")
            }
        }
        .displayName("Scan NovoPen")
        .description("Open Glucosy and start a NovoPen NFC scan")
    }
}
