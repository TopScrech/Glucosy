import HealthKit

extension HealthKit {
    func readWeight() {
        Task {
            _ = try? await reloadWeightRecords()
        }
    }

    @discardableResult
    func reloadWeightRecords(fullHistory: Bool = false) async throws -> [Weight] {
        await restoreCachedRecords()
        try await withRecordRefresh(for: bodyMassType, fullHistory: fullHistory) { [self] in
            let samples = try await refreshedSamples(for: bodyMassType, fullHistory: fullHistory, existing: { self.weightRecords.map(\.sample) })
            applyWeightSamples(samples)
            await persistSamples(samples, for: bodyMassType)
        }
        return weightRecords
    }

    func applyWeightSamples(_ samples: [HKQuantitySample]) {
        weightRecords = samples.map { Weight(value: $0.quantity.doubleValue(for: weightUnit), sample: $0) }
    }
}
