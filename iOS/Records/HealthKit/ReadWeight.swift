import HealthKit
import OSLog

extension HealthKit {
    func readWeight() {
        let startDate = Calendar.current.date(byAdding: .month, value: -12, to: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let unit = weightUnit
        
        let query = HKSampleQuery(
            sampleType: bodyMassType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { _, results, error in
            if let error {
                Logger().error("Error retrieving weight data: \(error, privacy: .public)")
                return
            }
            
            guard let samples = results as? [HKQuantitySample] else {
                Logger().warning("Could not fetch weight samples")
                return
            }
            
            let records = samples.map { sample -> Weight in
                let value = sample.quantity.doubleValue(for: unit)
                
                return Weight(value: value, sample: sample)
            }
            
            Task { @MainActor in
                self.weightRecords = records
            }
        }
        
        store?.execute(query)
    }
}
