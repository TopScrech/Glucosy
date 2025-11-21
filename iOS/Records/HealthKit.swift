import HealthyKit

@Observable
final class HealthKit {
    var insulinRecords: [Insulin] = []
    var glucoseRecords: [Glucose] = []
    var carbsRecords:   [Carbohydrates] = []
    
    var store: HKHealthStore?
    var glucoseUnit = HKUnit(from: "mg/dl") /// mmol/L unavailible
    
    let glucoseType:  HKQuantityType = .bloodGlucose
    let insulinType:  HKQuantityType = .insulinDelivery
    let carbsType:    HKQuantityType = .dietaryCarbohydrates
    let bodyMassType: HKQuantityType = .bodyMass
    let bmiType:      HKQuantityType = .bodyMassIndex
    
    init() {
        if isAvailable {
            store = HKHealthStore()
        }
    }
    
    private var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    private var dataTypes: Set<HKQuantityType> {
        Set([glucoseType, insulinType, carbsType])
    }
    
    func authorize(_ handler: @escaping (Bool) -> Void) {
        store?.requestAuthorization(toShare: dataTypes, read: dataTypes) { success, error in
            guard let error else {
                return handler(success)
            }
            
            print(error.localizedDescription)
            handler(false)
        }
    }
    
    var isAuthorized: Bool {
        store?.authorizationStatus(for: glucoseType) == .sharingAuthorized
    }
    
    func getAuthorizationState(_ handler: @escaping (Bool) -> Void) {
        guard let store else {
            handler(false)
            return
        }
        
        store.getRequestStatusForAuthorization(toShare: dataTypes, read: dataTypes) { status, error in
            if let error {
                print(error.localizedDescription)
                handler(false)
                return
            }
            
            handler(status == .unnecessary)
        }
    }
}
