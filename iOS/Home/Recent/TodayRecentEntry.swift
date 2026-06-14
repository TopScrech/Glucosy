import ScrechKit

struct TodayRecentEntry: Identifiable {
    let id: String
    let destination: TodayMetricDestination
    let title: LocalizedStringKey
    let value: String?
    let unit: String?
    let date: Date
    let icon: String
    let color: Color
}
