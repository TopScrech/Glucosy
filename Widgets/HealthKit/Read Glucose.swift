import HealthKit

extension HealthKit {
    func readGlucose(predicate: NSPredicate? = nil) async -> [Glucose] {
        guard let store = self.store,
              let glucoseType
        else {
            print("HealthKit Store is not initialized or Carbohydrates Type is unavailable in HealthKit")
            return []
        }
                
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierEndDate,
            ascending: false
        )
        
                return await withCheckedContinuation { continuation in
                    let glucoseQuery = HKSampleQuery(sampleType: glucoseType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, results, error in
                        var loadedRecords: [Glucose] = []
        
                        if let error {
                            print("Error retrieving carbohydrate data: \(error.localizedDescription)")
                            continuation.resume(returning: [])
                            return
                        }
        
                        if let glucoseSamples = results as? [HKQuantitySample] {
                            for sample in glucoseSamples {
                                let glucoseValue = sample.quantity.doubleValue(for: self.glucoseUnit)
        
                                loadedRecords.append(.init(
                                    value: glucoseValue,
                                    date: sample.startDate,
                                    sample: sample
                                ))
                            }
                        }
        
                        continuation.resume(returning: loadedRecords)
                    }
        
                    store.execute(glucoseQuery)
                }
        
//        let query = HKSampleQuery(
//            sampleType: glucoseType,
//            predicate: predicate,
//            limit: HKObjectQueryNoLimit,
//            sortDescriptors: [sortDescriptor]
//        ) { query, results, error in
//            
//            guard let results = results as? [HKQuantitySample], error == nil else {
//                print("HealthKit error: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//            
//            let glucoseUnit = HKUnit(from: "mg/dL") // Adjust this unit as per your requirements
//            
//            samples = results.map { sample in
//                Glucose(
//                    value: sample.quantity.doubleValue(for: glucoseUnit),
//                    date: sample.startDate,
//                    sample: sample
//                )
//            }
//        }
//        
//        store.execute(query)
//        
//        return samples
    }
//}
//    func readCarbsForToday() async -> [Carbohydrates] {
//        guard let store = self.store,
//              let carbsType = HKQuantityType.dietaryCarbohydrates()
//        else {
//            print("HealthKit Store is not initialized or Carbohydrates Type is unavailable in HealthKit")
//            return []
//        }
//        
//        let endDate = Date()
//        let startDate = Calendar.current.startOfDay(for: endDate)
//        
//        let predicate = HKQuery.predicateForSamples(
//            withStart: startDate,
//            end: endDate,
//            options: .strictStartDate
//        )
//        
//        let sortDescriptor = NSSortDescriptor(
//            key: HKSampleSortIdentifierStartDate,
//            ascending: false
//        )
//        
//        return await withCheckedContinuation { continuation in
//            let carbsQuery = HKSampleQuery(sampleType: carbsType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, results, error in
//                var loadedRecords: [Carbohydrates] = []
//                
//                if let error {
//                    print("Error retrieving carbohydrate data: \(error.localizedDescription)")
//                    continuation.resume(returning: [])
//                    return
//                }
//                
//                if let carbsSamples = results as? [HKQuantitySample] {
//                    for sample in carbsSamples {
//                        let carbsValue = sample.quantity.doubleValue(for: .gram())
//                        
//                        loadedRecords.append(.init(
//                            value: Int(carbsValue),
//                            date: sample.startDate,
//                            sample: sample
//                        ))
//                    }
//                }
//                
//                continuation.resume(returning: loadedRecords)
//            }
//            
//            store.execute(carbsQuery)
//        }
//    }
}
