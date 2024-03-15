import HealthKit

extension HealthKit {
    func writeGlucose(_ glucoseData: [Glucose]) {
        guard let glucose = HKQuantityType.quantityType(forIdentifier: .bloodGlucose) else {
            return
        }
        
        let samples = glucoseData.map {
            HKQuantitySample(
                type: glucose,
                quantity: HKQuantity(unit: glucoseUnit, doubleValue: Double($0.value)),
                start: $0.date,
                end: $0.date,
                metadata: nil
            )
        }
        
        store?.save(samples) { [self] success, error in
            if let error {
                log("HealthKit: error while saving: \(error.localizedDescription)")
            }
            
            self.lastDate = samples.last?.endDate
        }
    }
}
