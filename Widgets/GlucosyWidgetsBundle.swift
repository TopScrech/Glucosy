import SwiftUI
import WidgetKit

@main
struct GlucosyWidgetsBundle: WidgetBundle {
    var body: some Widget {
        BasalReminderWidget()
        WeightWidgetA()
        WeightWidgetB()
    }
}
