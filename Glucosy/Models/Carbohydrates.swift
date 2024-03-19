import HealthKit

struct Carbohydrates: Hashable {
    var value: Int
    var date: Date
    var sample: HKQuantitySample?
}
