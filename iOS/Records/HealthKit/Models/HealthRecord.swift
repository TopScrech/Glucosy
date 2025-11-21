import HealthKit

protocol HealthRecord: Identifiable {
    var id: UUID                 { get }
    var value: Double            { get }
    var sample: HKQuantitySample { get }
    var date: Date               { get }
    var source: String           { get }
}

extension HealthRecord {
    var date: Date {
        sample.startDate
    }
    
    var source: String {
        "\(sample.sourceRevision.source.name) \(sample.sourceRevision.source.bundleIdentifier)"
    }
}

struct Carbs: @MainActor HealthRecord {
    let id = UUID()
    let value: Double
    let sample: HKQuantitySample
}

struct Glucose: @MainActor HealthRecord {
    let id = UUID()
    let value: Double
    let sample: HKQuantitySample
}

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
}
