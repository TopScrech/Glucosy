import HealthKit

extension HealthKit {
    func readGlucose(handler: (@Sendable ([Glucose]) -> Void)? = nil) {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        //        let startDate = Calendar.current.date(
        //            byAdding: .day,
        //            value: -7,
        ///           to: Date()
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
        ) { _, results, error in
            
            guard let results = results as? [HKQuantitySample] else {
                if let error {
                    print("HealthKit error:", error.localizedDescription)
                } else {
                    print("HealthKit: no records")
                }
                
                return
            }
            
            guard !results.isEmpty else { return }
            
            Task { @MainActor in
                let samples = results.map { sample -> Glucose in
                        .init(
                            value: sample.quantity.doubleValue(for: self.glucoseUnit),
                            sample: sample
                        )
                }
                
                self.glucoseRecords = samples
                handler?(samples)
            }
        }
        
        store?.execute(query)
    }
}
