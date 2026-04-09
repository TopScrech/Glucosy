import SwiftUI

struct TodayMetricData: Identifiable {
    let destination: TodayMetricDestination
    let title: String
    let value: String
    let unit: String?
    let icon: String
    let color: Color

    var id: TodayMetricDestination { destination }
}
