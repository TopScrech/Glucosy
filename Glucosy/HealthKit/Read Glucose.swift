import HealthKit

extension HealthKit {
    func readGlucose(limit: Int = 100, handler: (([Glucose]) -> Void)? = nil) {
        guard let glucoseType else {
            log("HealthKit error: unable to create glucose quantity type")
            return
        }
        
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierEndDate,
            ascending: false
        )
        
        let query = HKSampleQuery(
            sampleType: glucoseType,
            predicate: nil,
            limit: limit,
            sortDescriptors: [sortDescriptor]
            
        ) { [self] query, results, error in
            
            guard let results = results as? [HKQuantitySample] else {
                if let error {
                    log("HealthKit error: \(error.localizedDescription)")
                } else {
                    log("HealthKit: no records")
                }
                
                return
            }
            
            self.lastDate = results.first?.endDate
            
            if results.count > 0 {
                let values = results.enumerated().map {
                    Glucose(
                        Int($0.1.quantity.doubleValue(for: self.glucoseUnit)),
                        id: $0.0,
                        date: $0.1.endDate,
                        source: $0.1.sourceRevision.source.name + " " + $0.1.sourceRevision.source.bundleIdentifier
                    )
                }
                
                DispatchQueue.main.async {
                    self.main.history.storedValues = values
                    handler?(values)
                }
            }
        }
        
        store?.execute(query)
    }
}
