import HealthKit

extension HealthKit {
    @discardableResult
    func reloadBMIRecords(fullHistory: Bool = false, ifStale: Bool = false) async throws -> [BMI] {
        try await refreshRecords(
            for: bmiType,
            fullHistory: fullHistory,
            ifStale: ifStale,
            existing: { self.bmiRecords.map(\.sample) },
            apply: applyBMISamples
        )
        return bmiRecords
    }

    func applyBMISamples(_ samples: [HKQuantitySample]) {
        bmiRecords = samples.map { BMI(value: $0.quantity.doubleValue(for: bmiUnit), sample: $0) }
    }
}
