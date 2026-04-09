import SwiftUI
import HealthKit

struct Glucose: @MainActor HealthRecord {
    let id = UUID()
    let value: Double
    let sample: HKQuantitySample
    
    init(sample: HKQuantitySample) {
        self.sample = sample
        self.value = sample.quantity.doubleValue(for: HKUnit(from: "mg/dl")) /// mmol/L unavailible
    }
}
