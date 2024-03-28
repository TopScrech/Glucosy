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

extension HealthKit {
    func readCarbsForToday() async -> [Carbohydrates] {
        guard let store = self.store,
              let carbsType = HKQuantityType.dietaryCarbohydrates()
        else {
            print("HealthKit Store is not initialized or Carbohydrates Type is unavailable in HealthKit")
            return []
        }
        
        let endDate = Date()
        let startDate = Calendar.current.startOfDay(for: endDate)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false
        )
        
        return await withCheckedContinuation { continuation in
            let carbsQuery = HKSampleQuery(sampleType: carbsType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, results, error in
                var loadedRecords: [Carbohydrates] = []
                
                if let error {
                    print("Error retrieving carbohydrate data: \(error.localizedDescription)")
                    continuation.resume(returning: []) // Resuming with empty array in case of error
                    return
                }
                
                if let carbsSamples = results as? [HKQuantitySample] {
                    for sample in carbsSamples {
                        let carbsValue = sample.quantity.doubleValue(for: .gram())
                        
                        loadedRecords.append(.init(
                            value: Int(carbsValue),
                            date: sample.startDate,
                            sample: sample
                        ))
                    }
                }
                
                continuation.resume(returning: loadedRecords)
            }
            
            store.execute(carbsQuery)
        }
    }
}
