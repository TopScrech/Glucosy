import SwiftUI
import HealthKit

struct Carbs: @MainActor HealthRecord {
    var id: UUID { sample.uuid }
    let value: Double
    let sample: HKQuantitySample
    
    var color: Color {
        .orange
    }
}
