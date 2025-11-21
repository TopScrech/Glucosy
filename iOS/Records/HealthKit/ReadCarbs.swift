import HealthKit

extension HealthKit {
    func readCarbs() {
        let startDate = Calendar.current.date(byAdding: .month, value: -12, to: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType:      carbsType,
            predicate:       predicate,
            limit:           HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
            
        ) { _, results, error in
            if let error {
                print("Error retrieving carbs data:", error.localizedDescription)
                return
            }
            
            guard let samples = results as? [HKQuantitySample] else {
                print("Could not fetch carbs samples")
                return
            }
            
            let records = samples.compactMap { sample -> Carbs? in
                let value = sample.quantity.doubleValue(for: .gram())
                
                return Carbs(value: value, sample: sample)
            }
            
            Task { @MainActor in
                self.carbsRecords = records
            }
        }
        
        store?.execute(query)
    }
}
