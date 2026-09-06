import HealthKit

extension HealthKit {
    func readCarbs() {
        Task {
            _ = try? await reloadCarbsRecords()
        }
    }

    @discardableResult
    func reloadCarbsRecords(fullHistory: Bool = false) async throws -> [Carbs] {
        await restoreCachedRecords()
        try await withRecordRefresh(for: carbsType, fullHistory: fullHistory) { [self] in
            let samples = try await refreshedSamples(for: carbsType, fullHistory: fullHistory, existing: { self.carbsRecords.map(\.sample) })
            applyCarbsSamples(samples)
            await persistSamples(samples, for: carbsType)
        }
        return carbsRecords
    }

    func applyCarbsSamples(_ samples: [HKQuantitySample]) {
        carbsRecords = samples.map { Carbs(value: $0.quantity.doubleValue(for: .gram()), sample: $0) }
    }
}
