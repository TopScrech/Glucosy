import HealthKit
import OSLog

extension HealthKit {
    func writeWeight(value: Double, date: Date = .now) {
        let sample = HKQuantitySample(
            type: bodyMassType,
            quantity: .init(unit: weightUnit, doubleValue: value),
            start: date,
            end: date,
            metadata: nil
        )
        
        store?.save(sample) { [weak self] success, error in
            if let error {
                Logger().error("HealthKit: error while saving weight: \(error)")
                return
            }
            
            guard success else {
                Logger().warning("HealthKit: weight save returned false")
                return
            }
            
            Task { @MainActor in
                self?.weightRecords.insert(
                    Weight(value: value, sample: sample),
                    at: 0
                )
            }
        }
    }
}
