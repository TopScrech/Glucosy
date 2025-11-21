import HealthKit

extension HealthKit {
    func readCarbs() {
        // from 1 month ago to now
        let startDate = Calendar.current.date(
            byAdding: .month,
            value: -12,
            to: Date()
        )
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end:       Date(),
            options:   .strictStartDate
        )
        
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false
        )
        
        let query = HKSampleQuery(
            sampleType: carbsType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
            
        ) { query, results, error in
            
            if let error {
                print("Error retrieving insulin delivery data:", error.localizedDescription)
                return
            }
            
            guard let samples = results as? [HKQuantitySample] else {
                print("Could not fetch insulin delivery samples")
                return
            }
            
            var records: [Carbohydrates] = []
            
            for sample in samples {
                let value = sample.quantity.doubleValue(for: .gram())
                
                records.append(.init(
                    value:  value,
                    sample: sample
                ))
                
                DispatchQueue.main.async { [self] in
                    carbsRecords = records
                }
            }
        }
        
        store?.execute(query)
    }
}
