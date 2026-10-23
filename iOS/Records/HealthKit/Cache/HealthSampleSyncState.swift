import HealthKit

nonisolated struct HealthSampleSyncState: Sendable {
    let samples: [HKQuantitySample]
    let anchor: HKQueryAnchor
    let refreshedAt: Date
}
