import HealthKit
import OSLog

extension HealthKit {
    func readInsulin() {
        Task {
            _ = try? await reloadInsulinRecords()
        }
    }
    
    @discardableResult
    func reloadInsulinRecords() async throws -> [Insulin] {
        let records = try await loadInsulinRecords()
        insulinRecords = records
        return records
    }
    
    private func loadInsulinRecords() async throws -> [Insulin] {
        guard let store else {
            throw NSError(
                domain: "HealthKit",
                code: 3,
                userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available"]
            )
        }
        
        let startDate = Calendar.current.date(byAdding: .month, value: -12, to: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: insulinType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, results, error in
                if let error {
                    Logger().error("Error retrieving insulin delivery data: \(error)")
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let samples = results as? [HKQuantitySample] else {
                    Logger().warning("Could not fetch insulin delivery samples")
                    continuation.resume(returning: [])
                    return
                }
                
                let loadedRecords = samples.compactMap { sample -> Insulin? in
                    let unit = sample.quantity.doubleValue(for: .internationalUnit())
                    
                    guard
                        let insulinMetadata = sample.metadata,
                        let insulinCategory = insulinMetadata["HKInsulinDeliveryReason"] as? Int
                    else {
                        return nil
                    }
                    
                    let insulinType: InsulinType = insulinCategory == 1 ? .basal : .bolus
                    
                    return Insulin(value: unit, type: insulinType, sample: sample)
                }
                
                continuation.resume(returning: loadedRecords)
            }
            
            store.execute(query)
        }
    }
}
