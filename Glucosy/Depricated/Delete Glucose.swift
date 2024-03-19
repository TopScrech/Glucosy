//import HealthKit
//
//extension HealthKit {
//    func deleteGlucose(_ glucose: HKQuantitySample, completion: @escaping (Bool, Error?) -> Void) {
//        let glucoseType = glucose.sampleType
//        
//        let predicate = HKQuery.predicateForObjects(with: [glucose.uuid])
//        
//        let query = HKSampleQuery(
//            sampleType: glucoseType,
//            predicate: predicate,
//            limit: HKObjectQueryNoLimit,
//            sortDescriptors: nil
//            
//        ) { query, samples, error in
//            
//            guard let samples else {
//                completion(false, error)
//                return
//            }
//            
//            self.store?.delete(samples) { success, error in
//                completion(success, error)
//            }
//        }
//        
//        self.store?.execute(query)
//    }
//}
