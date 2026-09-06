import HealthKit

extension HealthKit {
    func reloadEnergyRecords(for kind: EnergyKind) async throws {
        guard let store else { return }

        let now = Date.now
        let start = MeasurementChartRange.year.interval(endingAt: now).start
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
        energyRecords[kind] = days.sorted { $0.date > $1.date }
        energyErrors[kind] = nil
    }

    func refreshEnergy(for kind: EnergyKind) async {
        do {
            try await reloadEnergyRecords(for: kind)
        } catch {
            energyErrors[kind] = error.localizedDescription
        }
    }

    var energyMetricCards: [TodayMetricData] {
        EnergyKind.allCases.map { kind in
            let today = energyRecords[kind]?.first { Calendar.current.isDateInToday($0.date) }
            return TodayMetricData(
                destination: kind.destination,
                title: kind.title,
                value: today?.value.formatted(.number.precision(.fractionLength(0))) ?? "-",
                unit: String(localized: "kcal"),
                icon: kind.icon,
                color: kind.color
            )
        }
    }
}
