import HealthKit

extension HealthKit {
    func reloadEnergyRecords(for kind: EnergyKind, fullHistory: Bool = false, ifStale: Bool = false) async throws {
        try await withRecordRefresh(for: kind.quantityType, fullHistory: fullHistory || recordAnchors[kind.quantityType.identifier] != nil, ifStale: ifStale) { [self] in
            try await loadEnergyRecords(for: kind, fullHistory: fullHistory)
        }
    }

    private func loadEnergyRecords(for kind: EnergyKind, fullHistory: Bool) async throws {
        guard let store else { throw HKError(.errorHealthDataUnavailable) }

        let now = Date.now
        let key = kind.quantityType.identifier
        if !cachedTypes.contains(key) {
            if let snapshot = try? await recordCache.loadEnergySync(for: key + "-days") {
                energyRecords[kind] = snapshot.days
                recordAnchors[key] = snapshot.anchor
            } else if let cached = try? await recordCache.loadEnergy(for: key + "-days") {
                energyRecords[kind] = cached
            }
            cachedTypes.insert(key)
        }
        var anchor = recordAnchors[key]
        let changes: HealthEnergyChanges?
        if fullHistory || anchor != nil {
            do {
                changes = try await energyChanges(for: kind, anchor: anchor, store: store)
            } catch {
                guard anchor != nil, (error as? HKError)?.code == .errorInvalidArgument else { throw error }
                anchor = nil
                changes = try await energyChanges(for: kind, anchor: nil, store: store)
            }
        } else {
            changes = nil
        }
        // Deleted objects contain UUIDs, not dates, so their daily totals need a full reconciliation
        let replacesHistory = changes != nil && (anchor == nil || changes?.hasDeletions == true)
        let start = Calendar.current.startOfDay(for: replacesHistory
            ? min(changes?.earliestDate ?? now, energyRecords[kind]?.last?.date ?? now)
            : min(changes?.earliestDate ?? recentRefreshStart, recentRefreshStart))
        let predicate = HKQuery.predicateForSamples(withStart: start, end: now)
        let descriptor = HKStatisticsCollectionQueryDescriptor(
            predicate: HKSamplePredicate.quantitySample(type: kind.quantityType, predicate: predicate),
            options: .cumulativeSum,
            anchorDate: Calendar.current.startOfDay(for: now),
            intervalComponents: DateComponents(day: 1)
        )
        let collection = try await descriptor.result(for: store)
        var days: [EnergyDay] = []
        collection.enumerateStatistics(from: start, to: now) { statistics, _ in
            if let quantity = statistics.sumQuantity() {
                days.append(EnergyDay(date: statistics.startDate, value: quantity.doubleValue(for: .kilocalorie())))
            }
        }
        let retained = replacesHistory ? [] : (energyRecords[kind] ?? []).filter { $0.date < start }
        var byDay: [Date: EnergyDay] = [:]
        for day in retained + days {
            byDay[day.date] = day
        }
        let updatedDays = byDay.values.sorted { $0.date > $1.date }
        if let changes {
            try await recordCache.saveEnergySync(updatedDays, anchor: changes.anchor, refreshedAt: .now, for: key + "-days")
            recordAnchors[key] = changes.anchor
        } else {
            try await recordCache.saveEnergy(updatedDays, for: key + "-days")
        }
        energyRecords[kind] = updatedDays
        energyErrors[kind] = nil
    }

    private func energyChanges(for kind: EnergyKind, anchor: HKQueryAnchor?, store: HKHealthStore) async throws -> HealthEnergyChanges {
        var nextAnchor = anchor
        var earliestDate: Date?
        var hasDeletions = false
        // Bound peak memory without retaining raw energy samples in the cache
        while true {
            try Task.checkCancellation()
            let result = try await anchoredChanges(for: kind.quantityType, anchor: nextAnchor, store: store, limit: 1_000)
            if let first = result.addedSamples.map(\.startDate).min() {
                earliestDate = min(earliestDate ?? first, first)
            }
            hasDeletions = hasDeletions || !result.deletedObjects.isEmpty
            nextAnchor = result.newAnchor
            if result.addedSamples.isEmpty, result.deletedObjects.isEmpty {
                return HealthEnergyChanges(anchor: result.newAnchor, earliestDate: earliestDate, hasDeletions: hasDeletions)
            }
        }
    }

    func refreshEnergy(for kind: EnergyKind) async {
        do {
            try await reloadEnergyRecords(for: kind)
        } catch {
            energyErrors[kind] = error.localizedDescription
        }
    }

    var energyMetricCards: [TodayMetricData] {
        EnergyKind.allCases.map { energyMetricCard(for: $0) }
    }

    func energyToday(for kind: EnergyKind) -> Double? {
        energyRecords[kind]?.first { Calendar.current.isDateInToday($0.date) }?.value
    }

    func refreshCalories() async {
        for kind in EnergyKind.allCases {
            await refreshEnergy(for: kind)
        }
    }

    func energyMetricCard(for kind: EnergyKind) -> TodayMetricData {
        TodayMetricData(
            destination: kind.destination,
            title: kind.title,
            value: energyToday(for: kind)?.formatted(.number.precision(.fractionLength(0))) ?? "-",
            unit: String(localized: "kcal"),
            icon: kind.icon,
            color: kind.color
        )
    }
}
