import Foundation

// The payload and its anchor must always be committed in the same atomic file
nonisolated struct HealthSyncSnapshot<Payload: Codable & Sendable>: Codable, Sendable {
    let payload: Payload
    let anchor: Data
    let refreshedAt: Date
}
