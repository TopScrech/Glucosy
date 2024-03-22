import WidgetKit

struct GlucoseEntry: TimelineEntry {
    let glucose: String
    let measureDate: Date
    let unit: String
    let date: Date
    let configuration: ACGlucoseConfiguration
}
