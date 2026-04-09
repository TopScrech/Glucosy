import HealthKit
import OSLog

extension HealthKit {
    func writeCarbs(value: Double, date: Date = .now) {
        let sample = HKQuantitySample(
            type: carbsType,
            quantity: .init(unit: .gram(), doubleValue: value),
            start: date,
            end: date,
            metadata: nil
        )

        store?.save(sample) { [weak self] success, error in
            if let error {
                Logger().error("HealthKit: error while saving carbs: \(error)")
                return
            }

            guard success else {
                Logger().warning("HealthKit: carbs save returned false")
                return
            }

            Task { @MainActor in
                self?.carbsRecords.insert(
                    Carbs(value: value, sample: sample),
                    at: 0
                )
            }
        }
    }

    func writeCarbs(_ data: Carbs...) {
        let samples = data.map {
            HKQuantitySample(
                type: carbsType,
                quantity: .init(unit: .gram(), doubleValue: $0.value),
                start: $0.date,
                end: $0.date,
                metadata: nil
            )
        }
        
        store?.save(samples) { _, error in
            if let error {
                Logger().error("HealthKit: error while saving carbs: \(error)")
            }
        }
    }
}
