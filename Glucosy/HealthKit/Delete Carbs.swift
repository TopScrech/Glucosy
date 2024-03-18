import HealthKit

extension HealthKit {
    func deleteCarbohydrate(completion: @escaping (Bool, Error?) -> Void) {
        guard let carbsType else {
            return
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: Date.distantPast,
            end: Date(),
            options: .strictStartDate
        )
        
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
