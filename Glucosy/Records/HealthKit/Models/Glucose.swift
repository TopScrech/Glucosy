import HealthKit

struct Glucose: Identifiable {
    let id = UUID()
    
    let value: Double
    let sample: HKQuantitySample
    
    var date: Date {
        sample.startDate
    }
    
    var source: String {
        "\(sample.sourceRevision.source.name) \(sample.sourceRevision.source.bundleIdentifier)"
    }
}
