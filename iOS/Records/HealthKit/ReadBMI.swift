import HealthKit

extension HealthKit {
    func readBMI() {
        Task {
            _ = try? await reloadBMIRecords()
        }
    }

    @discardableResult
    func reloadBMIRecords(fullHistory: Bool = false) async throws -> [BMI] {
        await restoreCachedRecords()
        try await withRecordRefresh(for: bmiType, fullHistory: fullHistory) { [self] in
            let samples = try await refreshedSamples(for: bmiType, fullHistory: fullHistory, existing: { self.bmiRecords.map(\.sample) })
            applyBMISamples(samples)
            await persistSamples(samples, for: bmiType)
        }
        return bmiRecords
    }

    func applyBMISamples(_ samples: [HKQuantitySample]) {
        bmiRecords = samples.map { BMI(value: $0.quantity.doubleValue(for: bmiUnit), sample: $0) }
    }
}
