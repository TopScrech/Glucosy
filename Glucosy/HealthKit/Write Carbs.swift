import HealthKit

extension HealthKit {
    func writeCarbs(_ data: Carbohydrates...) {
        guard let carbsType else {
            return
        }
        
        let samples = data.map {
            HKQuantitySample(
                type: carbsType,
                quantity: .init(
                    unit: .gram(),
                    doubleValue: Double($0.value)
                ),
                start: $0.date,
                end: $0.date,
                metadata: nil
            )
        }
        
        store?.save(samples) { [self] _, error in
            if let error {
                log("HealthKit: error while saving carbs: \(error.localizedDescription)")
            }
        }
    }
}
