import HealthKit

extension HealthKit {
    @discardableResult
    func reloadCarbsRecords(fullHistory: Bool = false, ifStale: Bool = false) async throws -> [Carbs] {
        try await refreshRecords(
            for: carbsType,
            fullHistory: fullHistory,
            ifStale: ifStale,
            existing: { self.carbsRecords.map(\.sample) },
            apply: applyCarbsSamples
        )
        return carbsRecords
    }

    func applyCarbsSamples(_ samples: [HKQuantitySample]) {
        carbsRecords = samples.map { Carbs(value: $0.quantity.doubleValue(for: .gram()), sample: $0) }
    }
}
