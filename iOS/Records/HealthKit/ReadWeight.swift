import HealthKit
import OSLog

extension HealthKit {
    func readWeight() {
        Task {
            _ = try? await reloadWeightRecords()
        }
    }
    
    @discardableResult
    func reloadWeightRecords() async throws -> [Weight] {
        let records = try await loadWeightRecords()
        weightRecords = records
        return records
    }
    
    private func loadWeightRecords() async throws -> [Weight] {
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
        let unit = weightUnit
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: bodyMassType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, results, error in
                if let error {
                    Logger().error("Error retrieving weight data: \(error, privacy: .public)")
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let samples = results as? [HKQuantitySample] else {
                    Logger().warning("Could not fetch weight samples")
                    continuation.resume(returning: [])
                    return
                }
                
                let records = samples.map { sample -> Weight in
                    let value = sample.quantity.doubleValue(for: unit)
                    
                    return Weight(value: value, sample: sample)
                }
                
                continuation.resume(returning: records)
            }
            
            store.execute(query)
        }
    }
}
