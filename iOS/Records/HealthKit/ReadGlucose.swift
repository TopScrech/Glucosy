import HealthKit

extension HealthKit {
    @discardableResult
    func reloadGlucoseRecords(fullHistory: Bool = false, ifStale: Bool = false) async throws -> [Glucose] {
        try await refreshRecords(
            for: glucoseType,
            fullHistory: fullHistory,
            ifStale: ifStale,
            existing: { self.glucoseRecords.map(\.sample) },
            apply: applyGlucoseSamples
        )
        return glucoseRecords
    }

    func applyGlucoseSamples(_ samples: [HKQuantitySample]) {
        glucoseRecords = samples.map { Glucose(sample: $0) }
    }
}
