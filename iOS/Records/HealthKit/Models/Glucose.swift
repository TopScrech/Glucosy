import HealthKit

struct Glucose: @MainActor HealthRecord {
    var id: UUID { sample.uuid }
    let value: Double
    let sample: HKQuantitySample
    
    init(sample: HKQuantitySample) {
        self.sample = sample
        self.value = sample.quantity.doubleValue(for: HKUnit(from: "mg/dl")) /// mmol/L unavailible
    }
}
