import HealthKit

extension HealthKit {
    func readGlucose(handler: (([Glucose]) -> Void)? = nil) {
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierEndDate,
            ascending: false
        )
        
        //        let startDate = Calendar.current.date(
        //            byAdding: .day,
        //            value: -7,
        //            to: Date()
        //        )
        //
        //        let predicate = HKQuery.predicateForSamples(
        //            withStart: startDate,
        //            end:       Date(),
        //            options:   .strictStartDate
        //        )
        
        let query = HKSampleQuery(
            sampleType: glucoseType,
            //            predicate:  predicate,
            predicate:  nil,
            limit:      HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
            
        ) { [self] query, results, error in
            
            guard let results = results as? [HKQuantitySample] else {
                if let error {
                    print("HealthKit error:", error.localizedDescription)
                } else {
                    print("HealthKit: no records")
                }
                
                return
            }
            
            if results.count > 0 {
                let samples = results.enumerated().map { index, sample -> Glucose in
                        .init(
                            value: sample.quantity.doubleValue(for: glucoseUnit),
                            //                            id: index,
                            sample: sample
                        )
                }
                
                DispatchQueue.main.async { [self] in
                    glucoseRecords = samples
                    handler?(samples)
                }
            }
        }
        
        store?.execute(query)
    }
}
