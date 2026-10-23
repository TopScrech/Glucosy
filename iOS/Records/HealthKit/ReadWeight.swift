import HealthKit

extension HealthKit {
    @discardableResult
    func reloadWeightRecords(fullHistory: Bool = false, ifStale: Bool = false) async throws -> [Weight] {
        try await refreshRecords(
            for: bodyMassType,
            fullHistory: fullHistory,
            ifStale: ifStale,
            existing: { self.weightRecords.map(\.sample) },
            apply: applyWeightSamples
        )
        return weightRecords
    }

    func applyWeightSamples(_ samples: [HKQuantitySample]) {
        weightRecords = samples.map { Weight(value: $0.quantity.doubleValue(for: weightUnit), sample: $0) }
    }
}
