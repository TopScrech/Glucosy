import HealthKit

extension HealthKit {
    func readCarbsForToday() async -> [Carbohydrates] {
        guard let store = self.store,
              let carbsType = HKQuantityType.dietaryCarbohydrates()
        else {
            print("HealthKit Store is not initialized or Carbohydrates Type is unavailable in HealthKit")
            return []
        }
        
        let endDate = Date()
        let startDate = Calendar.current.startOfDay(for: endDate)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false
        )
        
        return await withCheckedContinuation { continuation in
            let carbsQuery = HKSampleQuery(sampleType: carbsType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, results, error in
                var loadedRecords: [Carbohydrates] = []
                
                if let error {
                    print("Error retrieving carbohydrate data: \(error.localizedDescription)")
                    continuation.resume(returning: [])
                    return
                }
                
                if let carbsSamples = results as? [HKQuantitySample] {
                    for sample in carbsSamples {
                        let carbsValue = sample.quantity.doubleValue(for: .gram())
                        
                        loadedRecords.append(.init(
                            value: Int(carbsValue),
                            date: sample.startDate,
                            sample: sample
                        ))
                    }
                }
                
                continuation.resume(returning: loadedRecords)
            }
            
            store.execute(carbsQuery)
        }
    }
}
