import HealthyKit
import OSLog

@Observable
final class HealthKit {
    var insulinRecords: [Insulin] = []
    var glucoseRecords: [Glucose] = []
    var carbsRecords:   [Carbs] = []
    var weightRecords:  [Weight] = []
    var bmiRecords:     [BMI] = []
    
    var energyRecords: [EnergyKind: [EnergyDay]] = [:]
    var energyErrors: [EnergyKind: String] = [:]

    let recordCache = HealthRecordCache()
    var cacheRestoreTask: Task<Void, Never>?
    var restoredCache = false
    var cachedTypes: Set<String> = []
    var cachedSamples: [String: [HKQuantitySample]] = [:]
    var isReloading = false
    var recordRefreshTasks: [String: Task<Void, Error>] = [:]
    var fullHistoryRefreshes: Set<String> = []

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
        Set([glucoseType, insulinType, carbsType, bodyMassType, bmiType] + EnergyKind.allCases.map(\.quantityType))
    }
    
    private var shareTypes: Set<HKSampleType> {
        Set([glucoseType, insulinType, carbsType, bodyMassType, bmiType, EnergyKind.dietary.quantityType])
    }
    
    func requestAuthorization() async throws {
        try await store?.requestAuthorization(toShare: shareTypes, read: readTypes)
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
        guard !isReloading else { return }
        isReloading = true
        defer { isReloading = false }
        await restoreCachedRecords()
        let glucoseLoaded = (try? await reloadGlucoseRecords()) != nil
        let insulinLoaded = (try? await reloadInsulinRecords()) != nil
        let carbsLoaded = (try? await reloadCarbsRecords()) != nil
        let weightLoaded = (try? await reloadWeightRecords()) != nil
        let bmiLoaded = (try? await reloadBMIRecords()) != nil
        var loadedEnergy: [EnergyKind] = []
        for kind in EnergyKind.allCases {
            do {
                try await reloadEnergyRecords(for: kind)
                loadedEnergy.append(kind)
            } catch {
                energyErrors[kind] = error.localizedDescription
            }
        }

        // Recent results are already visible while the complete history refresh runs
        if glucoseLoaded { _ = try? await reloadGlucoseRecords(fullHistory: true) }
        if insulinLoaded { _ = try? await reloadInsulinRecords(fullHistory: true) }
        if carbsLoaded { _ = try? await reloadCarbsRecords(fullHistory: true) }
        if weightLoaded { _ = try? await reloadWeightRecords(fullHistory: true) }
        if bmiLoaded { _ = try? await reloadBMIRecords(fullHistory: true) }
        for kind in loadedEnergy {
            do {
                try await reloadEnergyRecords(for: kind, fullHistory: true)
            } catch {
                energyErrors[kind] = error.localizedDescription
            }
        }
    }
}
