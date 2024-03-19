import HealthKit

extension HealthKit {
    func delete(_ sample: HKQuantitySample, completion: @escaping (Bool, Error?) -> Void) {
        let carbsType = sample.sampleType
        
        let predicate = HKQuery.predicateForObjects(with: [sample.uuid])
        
        let query = HKSampleQuery(
            sampleType: carbsType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
            
        ) { query, samples, error in
            
            guard let samples else {
                completion(false, error)
                return
            }
            
            self.store?.delete(samples) { success, error in
                completion(success, error)
            }
        }
        
        self.store?.execute(query)
    }
}
