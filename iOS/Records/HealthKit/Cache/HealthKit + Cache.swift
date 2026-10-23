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

    func withRecordRefresh(for type: HKQuantityType, fullHistory: Bool, ifStale: Bool = false, operation: @escaping () async throws -> Void) async throws {
        let key = type.identifier
        
        while let task = recordRefreshTasks[key] {
            let includesHistory = fullHistoryRefreshes.contains(key)
            try await task.value
            if !fullHistory || includesHistory { return }
        }
        
        if ifStale, refreshStates[key]?.isFresh(fullHistory: fullHistory) == true { return }

        let task = Task {
            defer {
                recordRefreshTasks[key] = nil
                fullHistoryRefreshes.remove(key)
            }
            
            do {
                try await operation()
                refreshStates[key, default: HealthRefreshState()].recordSuccess(fullHistory: fullHistory || recordAnchors[key] != nil)
            } catch {
                refreshStates[key] = nil
                throw error
            }
        }
        
        recordRefreshTasks[key] = task
        if fullHistory { fullHistoryRefreshes.insert(key) }
        try await task.value
    }

    var recentRefreshStart: Date {
        Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now)
    }

    func refreshedSamples(for type: HKQuantityType, existing: () -> [HKQuantitySample]) async throws -> [HKQuantitySample] {
        guard let store else {
            throw NSError(domain: "HealthKit", code: 3, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available"])
        }
        let start = recentRefreshStart
        let end = Date.now
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.quantitySample(type: type, predicate: predicate)],
            sortDescriptors: [SortDescriptor(\HKQuantitySample.startDate, order: .reverse)]
        )
        let fetched = try await descriptor.result(for: store)
        // Before history is opened, replace only the bounded launch window
        let samples = HealthRecordMerge.merge(
            existing: existing(),
            incoming: fetched,
            replacing: DateInterval(start: start, end: end),
            id: \.uuid,
            date: \.startDate
        )
        return samples
    }

    func uniqueSamples(_ samples: [HKQuantitySample]) -> [HKQuantitySample] {
        HealthRecordMerge.merge(existing: [], incoming: samples, id: \.uuid, date: \.startDate)
    }

    func persistSamples(_ samples: [HKQuantitySample], for type: HKQuantityType) async {
        do {
            if let anchor = recordAnchors[type.identifier] {
                try await recordCache.saveSampleSync(samples, anchor: anchor, refreshedAt: .distantPast, for: type.identifier)
            } else if cachedTypes.contains(type.identifier) {
                try await recordCache.saveSamples(samples, for: type.identifier)
            } else {
                try await recordCache.saveStartupSamples(samples, for: type.identifier)
            }
        } catch {
            Logger().error("Could not save health record cache: \(error)")
        }
    }

    func persistCurrentRecords() async {
        // Local writes must not hide external changes behind the freshness window
        refreshStates.removeAll()
        // Persist the current snapshot atomically after an app write or deletion
        for type in [glucoseType, insulinType, carbsType, bodyMassType, bmiType] {
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
