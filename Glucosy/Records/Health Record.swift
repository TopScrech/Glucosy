import HealthKit

struct HealthRecord: Identifiable {
    let id = UUID()
    
    let value: Double
    let date: Date
    let source: String
    let sample: HKQuantitySample
}
