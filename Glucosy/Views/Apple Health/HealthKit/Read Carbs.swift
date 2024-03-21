import HealthKit

extension HealthKit {
    func readCarbs() {
        guard let carbsType else {
            print("Carbohydrates Type is unavailable in HealthKit")
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
            end: endDate,
            options: .strictStartDate
        )
        
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false
        )
        
        let insulinQuery = HKSampleQuery(
            sampleType: carbsType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
            
        ) { query, results, error in
            
            if let error {
                print("Error retrieving insulin delivery data: \(error.localizedDescription)")
                return
            }
            
            guard let insulinSamples = results as? [HKQuantitySample] else {
                print("Could not fetch insulin delivery samples")
                return
            }
            
            var loadedRecords: [Carbohydrates] = []
            
            for sample in insulinSamples {
                let carbsUnit = sample.quantity.doubleValue(for: .gram())
                
                loadedRecords.append(.init(
                    value: Int(carbsUnit),
                    date: sample.startDate,
                    sample: sample
                ))
                
                DispatchQueue.main.async {
                    self.main.history.consumedCarbohydrates = loadedRecords
                }
            }
        }
        
        store?.execute(insulinQuery)
    }
}
