import HealthKit

struct BodyTemperature: Hashable {
    var value: Double
    var date: Date
    var sample: HKQuantitySample?
}
