import WidgetKit

struct SimpleEntry: TimelineEntry {
    let date: Date
    let weightEntries: [WeightWidgetEntry]
    let errorDescription: String?
}
