import HealthKit

extension HealthKit {
    func readGlucose(handler: (([Glucose]) -> Void)? = nil) {
        guard let glucoseType else {
            return
        }
        
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierEndDate,
            ascending: false
        )
        
//        let endDate = Date()
//        let startDate = Calendar.current.date(
//            byAdding: .day,
//            value: -7,
//            to: Date()
//        )
//        
//        let predicate = HKQuery.predicateForSamples(
//            withStart: startDate,
//            end:       endDate,
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
                    log("HealthKit error: \(error.localizedDescription)")
                } else {
                    log("HealthKit: no records")
                }
                
                return
            }
            
            self.lastDate = results.first?.endDate
            
            if results.count > 0 {
                let samples = results.enumerated().map { index, sample -> Glucose in
                        .init(
                            Int(sample.quantity.doubleValue(for: self.glucoseUnit)),
                            id: index,
                            date: sample.endDate,
                            source: "\(sample.sourceRevision.source.name) \(sample.sourceRevision.source.bundleIdentifier)",
                            sample: sample
                        )
                }
                
                DispatchQueue.main.async { [self] in
                    main.history.glucose = samples
                    handler?(samples)
                }
            }
        }
        
        store?.execute(query)
    }
}
