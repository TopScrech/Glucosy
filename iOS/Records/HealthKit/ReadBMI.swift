import HealthKit
import OSLog

extension HealthKit {
    func readBMI() {
        Task {
            _ = try? await reloadBMIRecords()
        }
    }
    
    @discardableResult
    func reloadBMIRecords() async throws -> [BMI] {
        let records = try await loadBMIRecords()
        bmiRecords = records
        
        return records
    }
    
    private func loadBMIRecords() async throws -> [BMI] {
        guard let store else {
            throw NSError(
                domain: "HealthKit",
                code: 4,
                userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available"]
            )
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let unit = bmiUnit
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: bmiType,
                predicate: nil,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, results, error in
                if let error {
                    Logger().error("Error retrieving BMI data: \(error)")
                    continuation.resume(throwing: error)
                    
                    return
                }
                
                guard let samples = results as? [HKQuantitySample] else {
                    Logger().warning("Could not fetch BMI samples")
                    continuation.resume(returning: [])
                    
                    return
                }
                
                let records = samples.map { sample in
                    let value = sample.quantity.doubleValue(for: unit)
                    
                    return BMI(value: value, sample: sample)
                }
                
                continuation.resume(returning: records)
            }
            
            store.execute(query)
        }
    }
}
