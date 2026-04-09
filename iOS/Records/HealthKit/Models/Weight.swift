import HealthKit

struct Weight: @MainActor HealthRecord {
    let id = UUID()
    let value: Double
    let sample: HKQuantitySample
}
