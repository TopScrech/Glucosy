import SwiftUI
import HealthKit

@Observable
final class WatchRecordsVM {
    private let store: HKHealthStore? = HKHealthStore.isHealthDataAvailable() ? HKHealthStore() : nil
    
    private(set) var authorizationMessage: String?
    private var prepared = false
    private var loadingKinds = Set<WatchRecordKind>()
    private var loadedKinds = Set<WatchRecordKind>()
    
    private var glucoseEntries = [WatchRecordEntry]()
    private var insulinEntries = [WatchRecordEntry]()
    private var carbsEntries = [WatchRecordEntry]()
    private var weightEntries = [WatchRecordEntry]()
    
    func prepare() async {
        _ = await ensureAuthorization()
    }
    
    func entries(for kind: WatchRecordKind) -> [WatchRecordEntry] {
        switch kind {
        case .glucose: glucoseEntries
        case .insulin: insulinEntries
        case .carbs: carbsEntries
        case .weight: weightEntries
        }
    }
    
    func isLoading(_ kind: WatchRecordKind) -> Bool {
        loadingKinds.contains(kind)
    }
    
    func loadIfNeeded(_ kind: WatchRecordKind) async {
        guard !loadedKinds.contains(kind) else {
            return
        }
        
        await refresh(kind)
    }
    
    func refresh(_ kind: WatchRecordKind) async {
        guard await ensureAuthorization() else {
            setEntries([], for: kind)
            return
        }
        
        loadingKinds.insert(kind)
        defer { loadingKinds.remove(kind) }
        
        do {
            let entries = try await loadEntries(for: kind)
            authorizationMessage = nil
            loadedKinds.insert(kind)
            setEntries(entries, for: kind)
        } catch {
            authorizationMessage = error.localizedDescription
            setEntries([], for: kind)
        }
    }
    
    private func setEntries(_ entries: [WatchRecordEntry], for kind: WatchRecordKind) {
        switch kind {
        case .glucose:
            glucoseEntries = entries
        case .insulin:
            insulinEntries = entries
        case .carbs:
            carbsEntries = entries
        case .weight:
            weightEntries = entries
        }
    }
    
    private func ensureAuthorization() async -> Bool {
        if prepared {
            return authorizationMessage == nil
        }
        
        prepared = true
        
        guard let store else {
            authorizationMessage = "Health data is unavailable on this watch"
            return false
        }
        
        do {
            try await requestAuthorization(using: store)
            authorizationMessage = nil
            return true
        } catch {
            authorizationMessage = "Allow Health access to view records"
            return false
        }
    }
    
    private func requestAuthorization(using store: HKHealthStore) async throws {
        let quantityTypes: Set<HKSampleType> = [
            HKQuantityType(.bloodGlucose),
            HKQuantityType(.insulinDelivery),
            HKQuantityType(.dietaryCarbohydrates),
            HKQuantityType(.bodyMass)
        ]
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            store.requestAuthorization(toShare: [], read: quantityTypes) { success, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: WatchRecordsError.authorizationDenied)
                }
            }
        }
    }
    
    private func loadEntries(for kind: WatchRecordKind) async throws -> [WatchRecordEntry] {
        switch kind {
        case .glucose:
            try await loadGlucoseEntries()
            
        case .insulin:
            try await loadInsulinEntries()
            
        case .carbs:
            try await loadCarbsEntries()
            
        case .weight:
            try await loadWeightEntries()
        }
    }
    
    private func loadGlucoseEntries() async throws -> [WatchRecordEntry] {
        let samples = try await loadSamples(for: .bloodGlucose)
        
        return samples.map {
            let usesMilligramsPerDeciliter = glucoseUnitRawValue == "mgdL"
            let milligramsPerDeciliter = $0.quantity.doubleValue(for: HKUnit(from: "mg/dl"))
            let convertedValue = usesMilligramsPerDeciliter ? milligramsPerDeciliter : milligramsPerDeciliter / 18.0182
            let valueText = usesMilligramsPerDeciliter
            ? convertedValue.formatted(.number.precision(.fractionLength(0)))
            : convertedValue.formatted(.number.precision(.fractionLength(0 ... 1)))
            
            return WatchRecordEntry(
                id: $0.uuid,
                timestamp: $0.startDate,
                systemImage: "drop",
                tint: .red,
                valueText: valueText,
                unitText: usesMilligramsPerDeciliter ? "mg/dL" : "mmol/L",
                detailText: nil
            )
        }
    }
    
    private func loadInsulinEntries() async throws -> [WatchRecordEntry] {
        let samples = try await loadSamples(for: .insulinDelivery)
        
        return samples.map {
            let insulinReason = $0.metadata?[HKMetadataKeyInsulinDeliveryReason] as? Int
            let detailText = insulinReason == HKInsulinDeliveryReason.basal.rawValue ? "Basal" : "Bolus"
            
            return WatchRecordEntry(
                id: $0.uuid,
                timestamp: $0.startDate,
                systemImage: detailText == "Basal" ? "syringe.fill" : "syringe",
                tint: detailText == "Basal" ? .purple : .yellow,
                valueText: $0.quantity.doubleValue(for: .internationalUnit()).formatted(.number.precision(.fractionLength(0 ... 1))),
                unitText: "U",
                detailText: detailText
            )
        }
    }
    
    private func loadCarbsEntries() async throws -> [WatchRecordEntry] {
        let samples = try await loadSamples(for: .dietaryCarbohydrates)
        
        return samples.map {
            WatchRecordEntry(
                id: $0.uuid,
                timestamp: $0.startDate,
                systemImage: "fork.knife",
                tint: .orange,
                valueText: $0.quantity.doubleValue(for: .gram()).formatted(.number.precision(.fractionLength(0 ... 1))),
                unitText: "g",
                detailText: nil
            )
        }
    }
    
    private func loadWeightEntries() async throws -> [WatchRecordEntry] {
        let samples = try await loadSamples(for: .bodyMass)
        
        return samples.map {
            WatchRecordEntry(
                id: $0.uuid,
                timestamp: $0.startDate,
                systemImage: "scalemass",
                tint: .blue,
                valueText: $0.quantity.doubleValue(for: .gramUnit(with: .kilo)).formatted(.number.precision(.fractionLength(0 ... 1))),
                unitText: "kg",
                detailText: nil
            )
        }
    }
    
    private func loadSamples(for identifier: HKQuantityTypeIdentifier) async throws -> [HKQuantitySample] {
        guard let store else {
            throw WatchRecordsError.healthDataUnavailable
        }
        
        let startDate = Calendar.current.date(byAdding: .month, value: -12, to: .now)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: .now, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let sampleType = HKQuantityType(identifier)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sampleType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, results, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                continuation.resume(returning: results as? [HKQuantitySample] ?? [])
            }
            
            store.execute(query)
        }
    }
    
    private var glucoseUnitRawValue: String {
        UserDefaults.standard.string(forKey: "glucose_unit") ?? "mmolL"
    }
}

private enum WatchRecordsError: LocalizedError {
    case authorizationDenied, healthDataUnavailable
    
    var errorDescription: String? {
        switch self {
        case .authorizationDenied: "Allow Health access to view records"
        case .healthDataUnavailable: "Health data is unavailable on this watch"
        }
    }
}
