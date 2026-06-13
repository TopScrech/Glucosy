import WidgetKit

extension HealthKit {
    func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
