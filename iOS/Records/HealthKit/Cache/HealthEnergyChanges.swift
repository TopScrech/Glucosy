import HealthKit

nonisolated struct HealthEnergyChanges: Sendable {
    let anchor: HKQueryAnchor
    let earliestDate: Date?
    let hasDeletions: Bool
}
