import ScrechKit
import HealthKit

// TODO: async / await
// TODO: Observers

@Observable
final class HealthKit {
    var store: HKHealthStore?
    var glucoseUnit = HKUnit(from: "mg/dl") /// mmol/L is unavailible
    var lastDate: Date?
    
    let glucoseType: HKQuantityType? = .bloodGlucose()
    let insulinType: HKQuantityType? = .insulinDelivery()
    let carbsType:   HKQuantityType? = .dietaryCarbohydrates()
    
    var loadedRecords: [Carbohydrates] = []
    
    init() {
        if isAvailable {
            store = HKHealthStore()
        }
    }
    
    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    private var dataTypes: Set<HKQuantityType> {
        guard let glucoseType,
              let insulinType,
              let carbsType
        else {
            return []
        }
        
        return Set([glucoseType, insulinType, carbsType])
    }
    
    func authorize(_ handler: @escaping (Bool) -> Void) {
        store?.requestAuthorization(dataTypes) { success, error in
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
        
        store?.getRequestStatusForAuthorization(dataTypes) { status, error in
            
            guard let error else {
                return handler(status == .unnecessary)
            }
            
            print(error.localizedDescription)
            handler(false)
        }
    }
}

