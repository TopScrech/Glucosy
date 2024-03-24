import HealthKit

extension HealthKit {
    func readTemperature() {
        guard let bodyTemperatureType else {
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
            sampleType: bodyTemperatureType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
            
        ) { query, results, error in
            
            if let error {
                print("Error retrieving Body Temperature data: \(error.localizedDescription)")
                return
            }
            
            guard let samples = results as? [HKQuantitySample] else {
                print("Could not fetch Body Temperature samples")
                return
            }
            
            var loadedRecords: [BodyTemperature] = []
            
            for sample in samples {
                let value = sample.quantity.doubleValue(for: .degreeCelsius())
                
                loadedRecords.append(.init(
                    value:  value,
                    date:   sample.startDate,
                    sample: sample
                ))
                
                DispatchQueue.main.async { [self] in
                    main.history.bodyTemperature = loadedRecords
                }
            }
        }
        
        store?.execute(query)
    }
}
