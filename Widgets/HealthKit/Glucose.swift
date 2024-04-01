import HealthKit

struct Glucose: Hashable {
    let value: Double
    let date: Date
    var sample: HKQuantitySample?
}
