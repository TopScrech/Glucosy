import HealthKit

extension HealthKit {
    func deleteGlucose(completion: @escaping (Bool, Error?) -> Void) {
        guard let glucoseType else {
            return
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: Date.distantPast,
            end: Date(),
            options: .strictStartDate
        )
        
        let query = HKSampleQuery(
            sampleType: glucoseType,
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
