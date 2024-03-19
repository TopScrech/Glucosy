import HealthKit

struct InsulinDelivery: Hashable {
    let value: Int
    let type: InsulinType
    let date: Date
    var sample: HKQuantitySample?
}
