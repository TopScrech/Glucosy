import HealthyKit
import OSLog

@Observable
final class HealthKit {
    var insulinRecords: [Insulin] = []
    var glucoseRecords: [Glucose] = []
    var carbsRecords:   [Carbs] = []
    var weightRecords:  [Weight] = []
    
    var store: HKHealthStore?
    var glucoseUnit = HKUnit(from: "mg/dl") /// mmol/L unavailible
    var weightUnit = HKUnit.gramUnit(with: .kilo)
    
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
        Set([glucoseType, insulinType, carbsType, bodyMassType])
    }
    
    func authorize(_ handler: @escaping @Sendable (Bool) -> Void) {
        store?.requestAuthorization(toShare: dataTypes, read: dataTypes) { success, error in
            guard let error else {
                return handler(success)
            }
            
            Logger().error("HealthKit authorization error: \(error, privacy: .public)")
            handler(false)
        }
    }
    
    var isAuthorized: Bool {
        store?.authorizationStatus(for: glucoseType) == .sharingAuthorized
    }
    
    func getAuthorizationState(_ handler: @escaping @Sendable (Bool) -> Void) {
        guard let store else {
            handler(false)
            return
        }
        
        store.getRequestStatusForAuthorization(toShare: dataTypes, read: dataTypes) { status, error in
            if let error {
                Logger().error("HealthKit authorization status error: \(error, privacy: .public)")
                handler(false)
                return
            }
            
            handler(status == .unnecessary)
        }
    }
    
    func reloadAllRecords() async {
        _ = try? await reloadGlucoseRecords()
        _ = try? await reloadInsulinRecords()
        _ = try? await reloadCarbsRecords()
        _ = try? await reloadWeightRecords()
    }
}
