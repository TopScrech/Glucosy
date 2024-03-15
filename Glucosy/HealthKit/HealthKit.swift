import HealthKit

// https://github.com/gshaviv/ninety-two/blob/master/WoofWoof/HealthKitManager.swift

// TODO: async / await
// TODO: Observers

class HealthKit: Logging {
    var main: MainDelegate!
    var store: HKHealthStore?
    var glucoseUnit = HKUnit(from: "mg/dl") /// mmol/L is unavailible
    var lastDate: Date?
    
    private let glucoseType = HKQuantityType.quantityType(forIdentifier: .bloodGlucose)
    private let insulinType = HKQuantityType.quantityType(forIdentifier: .insulinDelivery)
    private let carbsType = HKQuantityType.quantityType(forIdentifier: .dietaryCarbohydrates)
    
    init() {
        if isAvailable {
            store = HKHealthStore()
        }
    }
    
    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    private var healthKitTypes: Set<HKQuantityType> {
        guard let glucoseType, let insulinType, let carbsType else {
            return []
        }
        
        return Set([glucoseType, insulinType, carbsType])
    }
    
    func authorize(_ handler: @escaping (Bool) -> Void) {
        store?.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { success, error in
            if let error {
                print(error.localizedDescription)
                handler(false)
            } else {
                handler(success)
            }
        }
    }
    
    var isAuthorized: Bool {
        guard let glucoseType else {
            return false
        }
        
        return store?.authorizationStatus(for: glucoseType) == .sharingAuthorized
    }
    
    func getAuthorizationState(_ handler: @escaping (Bool) -> Void) {
        store?.getRequestStatusForAuthorization(toShare: healthKitTypes, read: healthKitTypes) { status, error in
            if let error {
                print(error.localizedDescription)
                handler(false)
            } else {
                handler(status == .unnecessary)
            }
        }
    }
    
//    func write(_ glucoseData: [Glucose]) {
//        guard let glucoseType = HKQuantityType.quantityType(forIdentifier: .bloodGlucose) else {
//            return
//        }
//        
//        let samples = glucoseData.map {
//            HKQuantitySample(
//                type: glucoseType,
//                quantity: HKQuantity(unit: glucoseUnit, doubleValue: Double($0.value)),
//                start: $0.date,
//                end: $0.date,
//                metadata: nil
//            )
//        }
//        
//        store?.save(samples) { [self] success, error in
//            if let error  {
//                log("HealthKit: error while saving: \(error.localizedDescription)")
//            }
//            self.lastDate = samples.last?.endDate
//        }
//    }
//    
//    func read(handler: (([Glucose]) -> Void)? = nil) {
//        guard let glucoseType = HKQuantityType.quantityType(forIdentifier: .bloodGlucose) else {
//            let msg = "HealthKit error: unable to create glucose quantity type"
//            log(msg)
//            return
//        }
//        
//        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
//        let query = HKSampleQuery(sampleType: glucoseType, predicate: nil, limit: 12 * 8, sortDescriptors: [sortDescriptor]) { [self] query, results, error in
//            guard let results = results as? [HKQuantitySample] else {
//                if let error {
//                    log("HealthKit error: \(error.localizedDescription)")
//                } else {
//                    log("HealthKit: no records")
//                }
//                return
//            }
//            
//            self.lastDate = results.first?.endDate
//            
//            if results.count > 0 {
//                let values = results.enumerated().map { Glucose(Int($0.1.quantity.doubleValue(for: self.glucoseUnit)), id: $0.0, date: $0.1.endDate, source: $0.1.sourceRevision.source.name + " " + $0.1.sourceRevision.source.bundleIdentifier) }
//                DispatchQueue.main.async { [self] in
//                    main.history.storedValues = values
//                    handler?(values)
//                }
//            }
//        }
//        
//        store?.execute(query)
//    }
}
