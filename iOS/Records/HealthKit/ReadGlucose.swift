import HealthKit

extension HealthKit {
    @discardableResult
    func reloadGlucoseRecords(fullHistory: Bool = false) async throws -> [Glucose] {
        await restoreCachedRecords()
        try await withRecordRefresh(for: glucoseType, fullHistory: fullHistory) { [self] in
            let samples = try await refreshedSamples(for: glucoseType, fullHistory: fullHistory, existing: { self.glucoseRecords.map(\.sample) })
            applyGlucoseSamples(samples)
            await persistSamples(samples, for: glucoseType)
        }
        return glucoseRecords
    }

    func applyGlucoseSamples(_ samples: [HKQuantitySample]) {
        glucoseRecords = samples.map { Glucose(sample: $0) }
    }
}
