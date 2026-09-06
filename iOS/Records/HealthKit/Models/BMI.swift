import HealthKit

struct BMI: @MainActor HealthRecord {
    var id: UUID { sample.uuid }
    let value: Double
    let sample: HKQuantitySample
}
