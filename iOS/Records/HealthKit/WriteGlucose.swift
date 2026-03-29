import HealthKit
import OSLog

extension HealthKit {
    func writeGlucose(value: Double, date: Date = .now) {
        let sample = HKQuantitySample(
            type: glucoseType,
            quantity: .init(unit: glucoseUnit, doubleValue: value),
            start: date,
            end: date,
            metadata: nil
        )

        store?.save(sample) { [weak self] success, error in
            if let error {
                Logger().error("HealthKit: error while saving glucose: \(error, privacy: .public)")
                return
            }

            guard success else {
                Logger().warning("HealthKit: glucose save returned false")
                return
            }

            Task { @MainActor in
                self?.glucoseRecords.insert(
                    Glucose(value: value, sample: sample),
                    at: 0
                )
            }
        }
    }

    func writeGlucose(_ data: [Glucose]) {
        let samples = data.map {
            HKQuantitySample(
                type: glucoseType,
                quantity: .init(unit: glucoseUnit, doubleValue: $0.value),
                start: $0.date,
                end: $0.date,
                metadata: nil
            )
        }
        
        store?.save(samples) { _, error in
            if let error {
                Logger().error("HealthKit: error while saving glucose: \(error, privacy: .public)")
            }
        }
    }
}
