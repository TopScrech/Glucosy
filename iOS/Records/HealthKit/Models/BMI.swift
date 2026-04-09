import HealthKit

struct BMI: @MainActor HealthRecord {
    let id = UUID()
    let value: Double
    let sample: HKQuantitySample
}
