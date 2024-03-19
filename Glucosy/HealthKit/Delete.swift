import HealthKit

extension HealthKit {
    func delete(_ sample: HKQuantitySample, completion: @escaping (Bool, Error?) -> Void) {
        store?.delete([sample]) { success, error in
            completion(success, error)
        }
    }
}
