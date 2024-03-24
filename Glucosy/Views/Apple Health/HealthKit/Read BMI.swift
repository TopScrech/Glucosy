import HealthKit

extension HealthKit {
    func readBMI() {
        guard let bmiType else {
            print("BMI is unavailable in HealthKit")
            return
        }
        
        // from 1 month ago to now
        let endDate = Date()
        let startDate = Calendar.current.date(
            byAdding: .month,
            value: -12,
            to: Date()
        )
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end:       endDate,
            options:   .strictStartDate
        )
        
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false
        )
        
        let query = HKSampleQuery(
            sampleType: bmiType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
            
        ) { query, results, error in
            
            if let error {
                print("Error retrieving BMI data: \(error.localizedDescription)")
                return
            }
            
            guard let samples = results as? [HKQuantitySample] else {
                print("Could not fetch BMI samples")
                return
            }
            
            var loadedRecords: [BMI] = []
            
            for sample in samples {
                let value = sample.quantity.doubleValue(for: .count())
                
                loadedRecords.append(.init(
                    value:  value,
                    date:   sample.startDate,
                    sample: sample
                ))
                
                DispatchQueue.main.async { [self] in
                    main.history.bmi = loadedRecords
                }
            }
        }
        
        store?.execute(query)
    }
}
