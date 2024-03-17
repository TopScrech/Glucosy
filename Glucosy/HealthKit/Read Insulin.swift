import HealthKit

extension HealthKit {
    func readInsulin() {
        guard let insulinType = HKObjectType.quantityType(forIdentifier: .insulinDelivery) else {
            print("Insulin Delivery Type is unavailable in HealthKit")
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
            sampleType: insulinType,
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
            
            var loadedRecords: [InsulinDelivery] = []
            
            // MARK: Metadata example: ["HKInsulinDeliveryReason": 2, "HKWasUserEntered": 1]
            
            for sample in insulinSamples {
                let insulinUnit = sample.quantity.doubleValue(for: .internationalUnit())
                print("Insulin Delivered: \(insulinUnit) IU, Date: \(sample.startDate) \(sample.metadata?.description ?? "")")
                
                if let insulinMetadata = sample.metadata,
                    let insulinCategory = insulinMetadata["HKInsulinDeliveryReason"] as? Int {
                    
                    var insulinType: InsulinType
                    insulinType = insulinCategory == 1 ? .basal : .bolus
                    
                    loadedRecords.append(.init(
                        value: Int(insulinUnit),
                        type: insulinType,
                        date: sample.startDate
                        //                        healthKitObject: sample
                    ))
                    
                    DispatchQueue.main.async {
                        self.main.history.insulinDeliveries = loadedRecords
                    }
                }
            }
        }
        
        store?.execute(insulinQuery)
    }
}
