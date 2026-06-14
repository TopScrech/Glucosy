import AppIntents
import ScrechKit
import WidgetKit

@available(iOS 18.0, *)
struct NovoPenScanWidgetContent: View {
    let entry: NovoPenScanEntry
    
    @Environment(\.widgetFamily) private var widgetFamily
    
    var body: some View {
        Button(intent: OpenNovoPenScanIntent()) {
            switch widgetFamily {
            case .accessoryInline:
                Label("Scan NovoPen", systemImage: "wave.3.right")
                
            case .accessoryRectangular:
                HStack {
                    Image(systemName: "wave.3.right")
                        .title3(.semibold, design: .rounded)
                    
                    Text("Start NFC scan")
                        .multilineTextAlignment(.trailing)
                        .footnote()
                        .secondary()
                }
                
            default:
                Image(systemName: "wave.3.right")
                    .title()
            }
        }
        .buttonStyle(.plain)
    }
}
