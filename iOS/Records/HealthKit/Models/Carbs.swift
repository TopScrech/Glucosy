import SwiftUI
import HealthKit

struct Carbs: @MainActor HealthRecord {
    let id = UUID()
    let value: Double
    let sample: HKQuantitySample
    
    var sourceID: String {
        self.sample.sourceRevision.source.bundleIdentifier
    }
    
    var color: Color {
        .orange
    }
}
