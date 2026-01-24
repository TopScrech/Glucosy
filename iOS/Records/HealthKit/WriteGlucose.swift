import HealthKit
import OSLog

extension HealthKit {
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

protocol Test {
    
}
