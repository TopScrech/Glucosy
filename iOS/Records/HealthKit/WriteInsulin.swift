import HealthKit
import OSLog

extension HealthKit {
    func writeInsulin(value: Double, type: InsulinType, date: Date = .now) {
        let sample = HKQuantitySample(
            type: insulinType,
            quantity: .init(unit: .internationalUnit(), doubleValue: value),
            start: date,
            end: date,
            metadata: [
                HKMetadataKeyInsulinDeliveryReason: type.healthKitValue
            ]
        )

        store?.save(sample) { [weak self] success, error in
            if let error {
                Logger().error("HealthKit: error while saving insulin: \(error, privacy: .public)")
                return
            }

            guard success else {
                Logger().warning("HealthKit: insulin save returned false")
                return
            }

            Task { @MainActor in
                self?.insulinRecords.insert(
                    Insulin(value: value, type: type, sample: sample),
                    at: 0
                )
            }
        }
    }
}
