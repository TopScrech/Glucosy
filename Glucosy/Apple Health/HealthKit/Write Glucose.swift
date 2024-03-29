import HealthKit

extension HealthKit {
    func writeGlucose(_ data: [Glucose]) {
        guard let glucoseType else {
            return
        }
        
        let samples = data.map {
            HKQuantitySample(
                type: glucoseType,
                quantity: .init(
                    unit: glucoseUnit,
                    doubleValue: Double($0.value)
                ),
                start: $0.date,
                end: $0.date,
                metadata: nil
            )
        }
        
        store?.save(samples) { [self] _, error in
            if let error {
                log("HealthKit: error while saving: \(error.localizedDescription)")
            }
            
            self.lastDate = samples.last?.endDate
        }
    }
}
