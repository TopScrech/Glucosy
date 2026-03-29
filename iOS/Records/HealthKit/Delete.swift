import HealthKit
import OSLog

extension HealthKit {
    func delete(
        _ sample: HKQuantitySample,
        completion: @escaping @Sendable (Bool, Error?) -> Void
    ) {
        store?.delete([sample]) { success, error in
            completion(success, error)
        }
    }

    func deleteGlucose(_ record: Glucose) {
        delete(record.sample) { [weak self] success, error in
            if let error {
                Logger().error("HealthKit: error while deleting glucose: \(error, privacy: .public)")
                return
            }

            guard success else {
                Logger().warning("HealthKit: glucose delete returned false")
                return
            }

            Task { @MainActor in
                self?.glucoseRecords.removeAll {
                    $0.sample.uuid == record.sample.uuid
                }
            }
        }
    }

    func deleteWeight(_ record: Weight) {
        delete(record.sample) { [weak self] success, error in
            if let error {
                Logger().error("HealthKit: error while deleting weight: \(error, privacy: .public)")
                return
            }

            guard success else {
                Logger().warning("HealthKit: weight delete returned false")
                return
            }

            Task { @MainActor in
                self?.weightRecords.removeAll {
                    $0.sample.uuid == record.sample.uuid
                }
            }
        }
    }
}
