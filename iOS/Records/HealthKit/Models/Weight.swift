import HealthKit

struct Weight: @MainActor HealthRecord {
    var id: UUID { sample.uuid }
    let value: Double
    let sample: HKQuantitySample
}
