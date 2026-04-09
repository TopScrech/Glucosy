import HealthKit
import OSLog

extension HealthKit {
    @discardableResult
    func reloadGlucoseRecords() async throws -> [Glucose] {
        let records = try await loadGlucoseRecords()
        glucoseRecords = records
        
        return records
    }
    
    private func loadGlucoseRecords() async throws -> [Glucose] {
        guard let store else {
            throw NSError(
                domain: "HealthKit",
                code: 3,
                userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available"]
            )
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: glucoseType,
                predicate: nil,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, results, error in
                if let error {
                    Logger().error("HealthKit error: \(error)")
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let results = results as? [HKQuantitySample] else {
                    Logger().warning("HealthKit: no records")
                    continuation.resume(returning: [])
                    return
                }
                
                Task { @MainActor in
                    let records = results.map { sample -> Glucose in
                        Glucose(sample: sample)
                    }
                    
                    continuation.resume(returning: records)
                }
            }
            
            store.execute(query)
        }
    }
}
