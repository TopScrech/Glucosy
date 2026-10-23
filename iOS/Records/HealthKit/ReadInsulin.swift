import HealthKit

extension HealthKit {
    func readInsulin() async {
        _ = try? await reloadInsulinRecords()
    }
    
    @discardableResult
    func reloadInsulinRecords(fullHistory: Bool = false, ifStale: Bool = false) async throws -> [Insulin] {
        
        try await refreshRecords(
            for: insulinType,
            fullHistory: fullHistory,
            ifStale: ifStale,
            existing: { self.insulinRecords.map(\.sample) },
            apply: applyInsulinSamples
        )
        return insulinRecords
    }
    
    func applyInsulinSamples(_ samples: [HKQuantitySample]) {
        insulinRecords = samples.map {
            Insulin(value: $0.quantity.doubleValue(for: .internationalUnit()), type: ($0.metadata?[HKMetadataKeyInsulinDeliveryReason] as? Int) == HKInsulinDeliveryReason.basal.rawValue ? .basal : .bolus, sample: $0)
        }
    }
}
