import WidgetKit

struct GlucoseEntry: TimelineEntry {
    let glucose: String
    let measureDate: Date
    let date: Date
    let configuration: ACGlucoseConfiguration
}
