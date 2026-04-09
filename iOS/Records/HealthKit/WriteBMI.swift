import HealthKit
import OSLog

extension HealthKit {
    func writeBMI(value: Double, date: Date = .now) {
        let sample = HKQuantitySample(
            type: bmiType,
            quantity: .init(unit: bmiUnit, doubleValue: value),
            start: date,
            end: date,
            metadata: nil
        )
        
        store?.save(sample) { [weak self] success, error in
            if let error {
                Logger().error("HealthKit: error while saving BMI: \(error)")
                return
            }
            
            guard success else {
                Logger().warning("HealthKit: BMI save returned false")
                return
            }
            
            Task { @MainActor in
                self?.bmiRecords.insert(
                    BMI(value: value, sample: sample),
                    at: 0
                )
            }
        }
    }
}
