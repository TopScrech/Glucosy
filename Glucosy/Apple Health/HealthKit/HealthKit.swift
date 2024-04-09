import HealthKit

// https://github.com/gshaviv/ninety-two/blob/master/WoofWoof/HealthKitManager.swift

// TODO: async / await
// TODO: Observers

final class HealthKit: Logging {
    var main: MainDelegate!
    var store: HKHealthStore?
    var glucoseUnit = HKUnit(from: "mg/dl") /// mmol/L unavailible
    var lastDate: Date?
    
    // TODO: Add workouts
    let glucoseType:         HKQuantityType? = .bloodGlucose()
    let insulinType:         HKQuantityType? = .insulinDelivery()
    let carbsType:           HKQuantityType? = .dietaryCarbohydrates()
    let bodyMassType:        HKQuantityType? = .bodyMass()
    let bmiType:             HKQuantityType? = .bodyMassIndex()
    
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
                let carbsType,
                let bodyMassType,
                let bmiType
        else {
            return []
        }
        
        return Set([glucoseType, insulinType, carbsType, bodyMassType, bmiType])
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
