import HealthKit

struct BodyMass: Hashable {
    var value: Double
    var date: Date
    var sample: HKQuantitySample?
}
