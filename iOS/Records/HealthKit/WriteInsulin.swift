import HealthKit
import OSLog

extension HealthKit {
    func writeInsulin(value: Double, type: InsulinType, date: Date = .now) async throws {
        let sample = HKQuantitySample(
            type: insulinType,
            quantity: .init(unit: .internationalUnit(), doubleValue: value),
            start: date,
            end: date,
            metadata: [
                HKMetadataKeyInsulinDeliveryReason: type.healthKitValue
            ]
        )
        
        try await save(sample)
        insulinRecords.insert(
            Insulin(value: value, type: type, sample: sample),
            at: 0
        )
    }
    
    private func save(_ sample: HKQuantitySample) async throws {
        guard let store else {
            throw NSError(
                domain: "HealthKit",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available"]
            )
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            store.save(sample) { success, error in
                if let error {
                    Logger().error("HealthKit: error while saving insulin: \(error)")
                    continuation.resume(throwing: error)
                    return
                }
                
                guard success else {
                    Logger().warning("HealthKit: insulin save returned false")
                    continuation.resume(
                        throwing: NSError(
                            domain: "HealthKit",
                            code: 2,
                            userInfo: [NSLocalizedDescriptionKey: "HealthKit could not save insulin"]
                        )
                    )
                    return
                }
                
                continuation.resume(returning: ())
            }
        }
    }
}
