import HealthKit
import OSLog

extension HealthKit {
    func restoreStartupRecords() {
        for type in [glucoseType, insulinType, carbsType, bodyMassType, bmiType] {
            if type == bodyMassType, savedWeight != nil { continue }
            if type == bmiType, savedBMI != nil { continue }
            do {
                guard let samples = try HealthRecordCache.loadStartupSamples(for: type.identifier) else { continue }
                switch type {
                case glucoseType: applyGlucoseSamples(samples)
                case insulinType: applyInsulinSamples(samples)
                case carbsType: applyCarbsSamples(samples)
                case bodyMassType: applyWeightSamples(samples)
                default: applyBMISamples(samples)
                }
            } catch {
                Logger().error("Could not restore startup records: \(error)")
            }
        }
        for kind in EnergyKind.allCases {
            do {
                energyRecords[kind] = try HealthRecordCache.loadStartupEnergy(for: kind.quantityType.identifier + "-days")
            } catch {
                Logger().error("Could not restore startup energy: \(error)")
            }
        }
    }

    func withRecordRefresh(for type: HKQuantityType, fullHistory: Bool, operation: @escaping () async throws -> Void) async throws {
        let key = type.identifier
        while let task = recordRefreshTasks[key] {
            let includesHistory = fullHistoryRefreshes.contains(key)
            try await task.value
            if !fullHistory || includesHistory { return }
        }
        let task = Task {
            defer {
                recordRefreshTasks[key] = nil
                fullHistoryRefreshes.remove(key)
            }
            try await operation()
        }
        recordRefreshTasks[key] = task
        if fullHistory { fullHistoryRefreshes.insert(key) }
        try await task.value
    }

    var recentRefreshStart: Date {
        Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now)
    }

    func restoreCachedRecords() async {
        if let cacheRestoreTask {
            await cacheRestoreTask.value
            return
        }
        guard !restoredCache else { return }
        let task = Task {
            for type in [glucoseType, insulinType, carbsType, bodyMassType, bmiType] + EnergyKind.allCases.map(\.quantityType) {
                do {
                    if let samples = try await recordCache.loadSamples(for: type.identifier) {
                        let samples = uniqueSamples(samples)
                        cachedSamples[type.identifier] = samples
                        switch type {
                        case glucoseType: applyGlucoseSamples(samples)
                        case insulinType: applyInsulinSamples(samples)
                        case carbsType: applyCarbsSamples(samples)
                        case bodyMassType: applyWeightSamples(samples)
                        case bmiType: applyBMISamples(samples)
                        default: break
                        }
                        cachedTypes.insert(type.identifier)
                    }
                } catch {
                    Logger().error("Could not restore health record cache: \(error)")
                }
            }
            for kind in EnergyKind.allCases {
                do {
                    if let days = try await recordCache.loadEnergy(for: kind.quantityType.identifier + "-days") {
                        energyRecords[kind] = days
                    }
                } catch {
                    Logger().error("Could not restore energy cache: \(error)")
                }
            }
            restoredCache = true
        }
        cacheRestoreTask = task
        await task.value
        cacheRestoreTask = nil
    }

    func refreshedSamples(for type: HKQuantityType, fullHistory: Bool = false, existing: () -> [HKQuantitySample]) async throws -> [HKQuantitySample] {
        guard let store else {
            throw NSError(domain: "HealthKit", code: 3, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available"])
        }
        let start = recentRefreshStart
        let end = Date.now
        let predicate = fullHistory ? nil : HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.quantitySample(type: type, predicate: predicate)],
            sortDescriptors: [SortDescriptor(\HKQuantitySample.startDate, order: .reverse)]
        )
        let fetched = try await descriptor.result(for: store)
        // A successful full fetch is authoritative, including deletions anywhere in history
        let samples = HealthRecordMerge.merge(
            existing: fullHistory ? [] : existing(),
            incoming: fetched,
            replacing: fullHistory ? nil : DateInterval(start: start, end: end),
            id: \.uuid,
            date: \.startDate
        )
        cachedSamples[type.identifier] = samples
        return samples
    }

    func uniqueSamples(_ samples: [HKQuantitySample]) -> [HKQuantitySample] {
        HealthRecordMerge.merge(existing: [], incoming: samples, id: \.uuid, date: \.startDate)
    }

    func persistSamples(_ samples: [HKQuantitySample], for type: HKQuantityType) async {
        do {
            try await recordCache.saveSamples(uniqueSamples(samples), for: type.identifier)
            cachedTypes.insert(type.identifier)
        } catch {
            Logger().error("Could not save health record cache: \(error)")
        }
    }

    func persistCurrentRecords() async {
        // Persist the current snapshot atomically after an app write or deletion
        for type in [glucoseType, insulinType, carbsType, bodyMassType, bmiType] where cachedTypes.contains(type.identifier) {
            let samples: [HKQuantitySample]
            switch type {
            case glucoseType: samples = glucoseRecords.map(\.sample)
            case insulinType: samples = insulinRecords.map(\.sample)
            case carbsType: samples = carbsRecords.map(\.sample)
            case bodyMassType: samples = weightRecords.map(\.sample)
            default: samples = bmiRecords.map(\.sample)
            }
            await persistSamples(samples, for: type)
        }
    }
}
