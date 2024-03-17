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
        store?.getRequestStatusForAuthorization(toShare: healthKitTypes, read: healthKitTypes) { status, error in
            guard let error else {
                return handler(status == .unnecessary)
            }
            
            print(error.localizedDescription)
            handler(false)
        }
    }
}
