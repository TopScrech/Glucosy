import HealthKit

extension HealthKit {
    func readInsulin() {
        Task {
            _ = try? await reloadInsulinRecords()
        }
    }

    @discardableResult
    func reloadInsulinRecords(fullHistory: Bool = false) async throws -> [Insulin] {
        await restoreCachedRecords()
        try await withRecordRefresh(for: insulinType, fullHistory: fullHistory) { [self] in
            let samples = try await refreshedSamples(for: insulinType, fullHistory: fullHistory, existing: { self.insulinRecords.map(\.sample) })
            applyInsulinSamples(samples)
            await persistSamples(samples, for: insulinType)
        }
        return insulinRecords
    }

    func applyInsulinSamples(_ samples: [HKQuantitySample]) {
        insulinRecords = samples.map { Insulin(value: $0.quantity.doubleValue(for: .internationalUnit()), type: ($0.metadata?[HKMetadataKeyInsulinDeliveryReason] as? Int) == HKInsulinDeliveryReason.basal.rawValue ? .basal : .bolus, sample: $0) }
    }
}
