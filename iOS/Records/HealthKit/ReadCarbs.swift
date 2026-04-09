import HealthKit
import OSLog

extension HealthKit {
    func readCarbs() {
        Task {
            _ = try? await reloadCarbsRecords()
        }
    }
    
    @discardableResult
    func reloadCarbsRecords() async throws -> [Carbs] {
        let records = try await loadCarbsRecords()
        carbsRecords = records
        return records
    }
    
    private func loadCarbsRecords() async throws -> [Carbs] {
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
                sampleType: carbsType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, results, error in
                if let error {
                    Logger().error("Error retrieving carbs data: \(error)")
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let samples = results as? [HKQuantitySample] else {
                    Logger().warning("Could not fetch carbs samples")
                    continuation.resume(returning: [])
                    return
                }
                
                let records = samples.map { sample -> Carbs in
                    let value = sample.quantity.doubleValue(for: .gram())
                    
                    return Carbs(value: value, sample: sample)
                }
                
                continuation.resume(returning: records)
            }
            
            store.execute(query)
        }
    }
}
