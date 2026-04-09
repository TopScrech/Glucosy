import HealthyKit
import OSLog

@Observable
final class HealthKit {
    var insulinRecords: [Insulin] = []
    var glucoseRecords: [Glucose] = []
    var carbsRecords:   [Carbs] = []
    var weightRecords:  [Weight] = []
    var bmiRecords:     [BMI] = []
    
    var store: HKHealthStore?
    var glucoseUnit = HKUnit(from: "mg/dl") /// mmol/L unavailible
    var weightUnit = HKUnit.gramUnit(with: .kilo)
    var bmiUnit = HKUnit.count()
    
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
    
    private var readTypes: Set<HKObjectType> {
        Set([glucoseType, insulinType, carbsType, bodyMassType, bmiType])
    }
    
    private var shareTypes: Set<HKSampleType> {
        Set([glucoseType, insulinType, carbsType, bodyMassType, bmiType])
    }
    
    func authorize(_ handler: @escaping @Sendable (Bool) -> Void) {
        store?.requestAuthorization(toShare: shareTypes, read: readTypes) { success, error in
            guard let error else {
                return handler(success)
            }
            
            Logger().error("HealthKit authorization error: \(error)")
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
        
        store.getRequestStatusForAuthorization(toShare: shareTypes, read: readTypes) { status, error in
            if let error {
                Logger().error("HealthKit authorization status error: \(error)")
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
        _ = try? await reloadBMIRecords()
    }
}
