import SwiftUI
import HealthKit

struct Insulin: @MainActor HealthRecord {
    var id: UUID { sample.uuid }
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
}
