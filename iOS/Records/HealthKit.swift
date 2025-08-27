import HealthyKit

@Observable
final class HealthKit {
    var insulinRecords: [Insulin] = []
    var glucoseRecords: [Glucose] = []
    var carbsRecords:   [Carbohydrates] = []
    
    var store: HKHealthStore?
    var glucoseUnit = HKUnit(from: "mg/dl") /// mmol/L unavailible
    
    let glucoseType:  HKQuantityType? = .bloodGlucose()
    let insulinType:  HKQuantityType? = .insulinDelivery()
    let carbsType:    HKQuantityType? = .dietaryCarbohydrates()
    let bodyMassType: HKQuantityType? = .bodyMass()
    let bmiType:      HKQuantityType? = .bodyMassIndex()
    
    init() {
        if isAvailable {
            store = HKHealthStore()
        }
    }
    
    private var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    private var dataTypes: Set<HKQuantityType> {
        if let glucoseType, let insulinType, let carbsType {
            Set([glucoseType, insulinType, carbsType])
        } else {
            []
        }
    }
    
    func authorize(_ handler: @escaping (Bool) -> Void) {
        store?.requestPermission(dataTypes) { success, error in
            guard let error else {
                return handler(success)
            }
            
            print(error.localizedDescription)
            handler(false)
        }
    }
    
    var isAuthorized: Bool {
        guard let glucoseType else {
            return false
        }
        
        return store?.authorizationStatus(for: glucoseType) == .sharingAuthorized
    }
    
    func getAuthorizationState(_ handler: @escaping (Bool) -> Void) {
        store?.getRequestStatusForPermission(dataTypes) { status, error in
            guard let error else {
                return handler(status == .unnecessary)
            }
            
            print(error.localizedDescription)
            handler(false)
        }
    }
}
