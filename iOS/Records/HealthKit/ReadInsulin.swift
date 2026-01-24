import HealthKit
import OSLog

extension HealthKit {
    func readInsulin() {
        let startDate = Calendar.current.date(byAdding: .month, value: -12, to: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType: insulinType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { _, results, error in
            if let error {
                Logger().error("Error retrieving insulin delivery data: \(error, privacy: .public)")
                return
            }
            
            guard let samples = results as? [HKQuantitySample] else {
                Logger().warning("Could not fetch insulin delivery samples")
                return
            }
            
            let loadedRecords = samples.compactMap { sample -> Insulin? in
                let unit = sample.quantity.doubleValue(for: .internationalUnit())
                
                guard
                    let insulinMetadata = sample.metadata,
                    let insulinCategory = insulinMetadata["HKInsulinDeliveryReason"] as? Int
                else {
                    return nil
                }
                
                let insulinType: InsulinType = insulinCategory == 1 ? .basal : .bolus
                
                return Insulin(value: unit, type: insulinType, sample: sample)
            }
            
            Task { @MainActor in
                self.insulinRecords = loadedRecords
            }
        }
        
        store?.execute(query)
    }
}
