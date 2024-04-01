import WidgetKit

struct ChartEntry: TimelineEntry {
    var date: Date
    let glucose: [Glucose]
    let unit: String
    let configuration: ChartConfiguration
}
