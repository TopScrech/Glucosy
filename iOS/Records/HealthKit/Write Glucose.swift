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
                    doubleValue: $0.value
                ),
                start: $0.date,
                end: $0.date,
                metadata: nil
            )
        }
        
        store?.save(samples) { _, error in
            if let error {
                print("HealthKit: error while saving: \(error.localizedDescription)")
            }
        }
    }
}

protocol Test {
    
}
