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
    
    var sourceID: String {
        self.sample.sourceRevision.source.bundleIdentifier
    }
    
    var source: String {
        "\(sample.sourceRevision.source.name) \(sourceID)"
    }
}
