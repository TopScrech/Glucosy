import HealthKit

struct BMI: Hashable {
    var value: Double
    var date: Date
    var sample: HKQuantitySample?
}
