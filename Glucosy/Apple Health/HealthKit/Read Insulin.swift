import HealthKit

extension HealthKit {
    func readInsulin() {
        guard let insulinType else {
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
        
        let query = HKSampleQuery(
            sampleType: insulinType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
            
        ) { query, results, error in
            
            if let error {
                print("Error retrieving insulin delivery data: \(error.localizedDescription)")
                return
            }
            
            guard let samples = results as? [HKQuantitySample] else {
                print("Could not fetch insulin delivery samples")
                return
            }
            
            var loadedRecords: [InsulinDelivery] = []
            
            // MARK: Metadata example: ["HKInsulinDeliveryReason": 2, "HKWasUserEntered": 1]
            
            for sample in samples {
                let unit = sample.quantity.doubleValue(for: .internationalUnit())
                
                if let insulinMetadata = sample.metadata,
                   let insulinCategory = insulinMetadata["HKInsulinDeliveryReason"] as? Int {
                    
                    var insulinType: InsulinType
                    insulinType = insulinCategory == 1 ? .basal : .bolus
                    
                    loadedRecords.append(.init(
                        value: Int(unit),
                        type: insulinType,
                        date: sample.startDate,
                        sample: sample
                    ))
                    
                    DispatchQueue.main.async {
                        self.main.history.insulin = loadedRecords
                    }
                }
            }
        }
        
        store?.execute(query)
    }
}
