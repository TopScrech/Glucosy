import SwiftUI
import HealthKit

struct Glucose: @MainActor HealthRecord {
    let id = UUID()
    let value: Double
    let sample: HKQuantitySample
}
