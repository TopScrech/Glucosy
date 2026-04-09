import SwiftUI
import HealthKit

struct Carbs: @MainActor HealthRecord {
    let id = UUID()
    let value: Double
    let sample: HKQuantitySample
    
    var color: Color {
        .orange
    }
}
