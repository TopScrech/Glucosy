import HealthKit
import OSLog

extension HealthKit {
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
                Logger().error("HealthKit: error while saving carbs: \(error, privacy: .public)")
            }
        }
    }
}
