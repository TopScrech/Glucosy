import SwiftUI
import HealthKit

struct Insulin: @MainActor HealthRecord {
    let id = UUID()
    let value: Double
    let type: InsulinType
    let sample: HKQuantitySample
    
    var formattedValue: String {
        value.truncatingRemainder(dividingBy: 1) == 0 ?
        String(format: "%.0f", value) :
        String(value)
    }
    
    private var isBasal: Bool {
        self.type == .basal
    }
    
    var icon: String {
        isBasal ? "syringe.fill" : "syringe"
    }
    
    var color: Color {
        isBasal ? .purple : .yellow
    }
    
    var sourceID: String {
        self.sample.sourceRevision.source.bundleIdentifier
    }
}
