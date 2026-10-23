import HealthyKit
import OSLog

@Observable
final class HealthKit {
    var insulinRecords: [Insulin] = [] {
        didSet { insulinDays = HealthRecordDay.group(insulinRecords) }
    }
    var glucoseRecords: [Glucose] = [] {
        didSet { glucoseDays = HealthRecordDay.group(glucoseRecords) }
    }
    var carbsRecords: [Carbs] = [] {
        didSet { carbsDays = HealthRecordDay.group(carbsRecords) }
    }
    
    var weightRecords: [Weight] = [] {
        didSet {
            weightDays = HealthRecordDay.group(weightRecords)
            updateLatestWeight()
        }
    }
    
    var bmiRecords: [BMI] = [] {
        didSet {
            bmiDays = HealthRecordDay.group(bmiRecords)
            updateLatestBMI()
        }
    }
    
    var glucoseDays: [HealthRecordDay<Glucose>] = []
    var insulinDays: [HealthRecordDay<Insulin>] = []
    var carbsDays: [HealthRecordDay<Carbs>] = []
    var weightDays: [HealthRecordDay<Weight>] = []
    var bmiDays: [HealthRecordDay<BMI>] = []

    var savedWeight: LatestHealthMeasurement?
    var savedBMI: LatestHealthMeasurement?
    
    var latestWeightRecord: Weight? {
        weightRecords.max { $0.date < $1.date }
    }
    
    var latestBMIRecord: BMI? {
        bmiRecords.max { $0.date < $1.date }
    }
    
    var energyRecords: [EnergyKind: [EnergyDay]] = [:]
    var energyErrors: [EnergyKind: String] = [:]
    
    let recordCache = HealthRecordCache()
    var isReady = false
    var cachedTypes: Set<String> = []
    var isReloading = false
    var recordRefreshTasks: [String: Task<Void, Error>] = [:]
    var fullHistoryRefreshes: Set<String> = []
    var recordAnchors: [String: HKQueryAnchor] = [:]
    var refreshStates: [String: HealthRefreshState] = [:]
    
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
        restoreLatestMeasurements()
        restoreStartupRecords()
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
    
    func reloadAllRecords() async {
        guard !isReloading else { return }
        isReloading = true
        defer { isReloading = false }
        async let glucose: Void = refreshRecentGlucose()
        async let insulin: Void = refreshRecentInsulin()
        async let carbs: Void = refreshRecentCarbs()
        async let weight: Void = refreshRecentWeight()
        async let bmi: Void = refreshRecentBMI()
        async let energy: Void = refreshCalories()
        _ = await (glucose, insulin, carbs, weight, bmi, energy)
    }

    private func refreshRecentGlucose() async { _ = try? await reloadGlucoseRecords() }
    private func refreshRecentInsulin() async { _ = try? await reloadInsulinRecords() }
    private func refreshRecentCarbs() async { _ = try? await reloadCarbsRecords() }
    private func refreshRecentWeight() async { _ = try? await reloadWeightRecords(fullHistory: true) }
    private func refreshRecentBMI() async { _ = try? await reloadBMIRecords(fullHistory: true) }
}
