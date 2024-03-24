import HealthKit

extension HealthKit {
    func writeTemperature(_ data: [Glucose]) {
        guard let bodyTemperatureType else {
            return
        }
        
        let nonZeroData = data.filter {
            $0.temperature != 0
        }
        
        let samples = data.map { glucose in
            HKQuantitySample(
                type: bodyTemperatureType,
                quantity: HKQuantity(
                    unit: .degreeCelsius(),
                    doubleValue: glucose.temperature
                ),
                start: glucose.date,
                end: glucose.date
            )
        }
        
        store?.save(samples) { [self] _, error in
            if let error {
                log("HealthKit: error while saving body temperature: \(error.localizedDescription)")
            }
        }
    }
}
