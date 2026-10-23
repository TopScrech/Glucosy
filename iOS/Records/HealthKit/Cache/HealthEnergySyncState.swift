import HealthKit

nonisolated struct HealthEnergySyncState: Sendable {
    let days: [EnergyDay]
    let anchor: HKQueryAnchor
    let refreshedAt: Date
}
