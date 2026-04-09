import SwiftUI
import HealthKit

struct Weight: @MainActor HealthRecord {
    let id = UUID()
    let value: Double
    let sample: HKQuantitySample
    
    var sourceID: String {
        self.sample.sourceRevision.source.bundleIdentifier
    }
}
