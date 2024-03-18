import HealthKit

extension HealthKit {
    func writeInsulinDelivery(_ data: [InsulinDelivery]) {
        guard let insulinType else {
            return
        }
        
        let samples = data.map {
            HKQuantitySample(
                type: insulinType,
                quantity: .init(
                    unit: .internationalUnit(),
                    doubleValue: Double($0.value)
                ),
                start: $0.date,
                end: $0.date,
                metadata: [
                    "HKInsulinDeliveryReason": $0.type == .basal ? 1 : 2
                ]
            )
        }
        
        store?.save(samples) { [self] _, error in
            if let error {
                log("HealthKit: error while saving insulin delivery: \(error.localizedDescription)")
            }
        }
    }
}
