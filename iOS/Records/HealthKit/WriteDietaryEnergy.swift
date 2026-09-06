import HealthKit

extension HealthKit {
    func writeDietaryEnergy(value: Double, date: Date) async throws {
        guard value.isFinite, value > 0 else {
            throw NSError(domain: "HealthKit", code: 1, userInfo: [
                NSLocalizedDescriptionKey: String(localized: "Enter an energy amount greater than zero")
            ])
        }
        guard let store else {
            throw NSError(domain: "HealthKit", code: 3, userInfo: [
                NSLocalizedDescriptionKey: String(localized: "HealthKit is not available")
            ])
        }

        try await requestAuthorization()
        let sample = HKQuantitySample(
            type: EnergyKind.dietary.quantityType,
            quantity: HKQuantity(unit: .kilocalorie(), doubleValue: value),
            start: date,
            end: date,
            metadata: [HKMetadataKeyWasUserEntered: true]
        )
        try await store.save(sample)
        await refreshEnergy(for: .dietary)
    }
}
