import HealthKit

extension HealthKit {
    func reloadEnergyRecords(for kind: EnergyKind, fullHistory: Bool = false) async throws {
        await restoreCachedRecords()
        try await withRecordRefresh(for: kind.quantityType, fullHistory: fullHistory) { [self] in
            try await loadEnergyRecords(for: kind, fullHistory: fullHistory)
        }
    }

    private func loadEnergyRecords(for kind: EnergyKind, fullHistory: Bool) async throws {
        guard let store else { return }

        let now = Date.now
        let key = kind.quantityType.identifier
        let previousSamples = cachedSamples[key] ?? []
        let samples = try await refreshedSamples(for: kind.quantityType, fullHistory: fullHistory, existing: { self.cachedSamples[key] ?? [] })
        let start = Calendar.current.startOfDay(for: fullHistory
            ? min(samples.last?.startDate ?? now, energyRecords[kind]?.last?.date ?? now)
            : recentRefreshStart)
        // Retry historical changes if the statistics query or cache write fails
        do {
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
            let retained = (energyRecords[kind] ?? []).filter { $0.date < start }
            var byDay: [Date: EnergyDay] = [:]
            for day in retained + days {
                byDay[day.date] = day
            }
            energyRecords[kind] = byDay.values.sorted { $0.date > $1.date }
            try await recordCache.saveEnergy(energyRecords[kind] ?? [], for: key + "-days")
            await persistSamples(samples, for: kind.quantityType)
            energyErrors[kind] = nil
        } catch {
            cachedSamples[key] = previousSamples
            throw error
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
