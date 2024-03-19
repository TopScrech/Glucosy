//import HealthKit
//
//extension HealthKit {
//    func deleteInsulin(completion: @escaping (Bool, Error?) -> Void) {
//        guard let insulinType else {
//            return
//        }
//        
//        let predicate = HKQuery.predicateForSamples(
//            withStart: Date.distantPast,
//            end: Date(),
//            options: .strictStartDate
//        )
//        
//        let query = HKSampleQuery(
//            sampleType: insulinType,
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
