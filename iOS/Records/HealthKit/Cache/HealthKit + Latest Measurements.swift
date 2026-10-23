import Foundation
import OSLog

extension HealthKit {
    func restoreLatestMeasurements() {
        do {
            savedWeight = try LatestHealthMeasurementCache.load(for: "weight")
        } catch {
            Logger().error("Could not load saved weight: \(error)")
        }
        do {
            savedBMI = try LatestHealthMeasurementCache.load(for: "bmi")
        } catch {
            Logger().error("Could not load saved BMI: \(error)")
        }
    }

    func updateLatestWeight() {
        let latest = latestWeightRecord.map {
            LatestHealthMeasurement(id: $0.id, date: $0.date, value: $0.value)
        }
        guard latest != savedWeight else { return }
        savedWeight = latest
        do {
            try LatestHealthMeasurementCache.save(savedWeight, for: "weight")
        } catch {
            Logger().error("Could not save latest weight: \(error)")
        }
    }

    func updateLatestBMI() {
        let latest = latestBMIRecord.map {
            LatestHealthMeasurement(id: $0.id, date: $0.date, value: $0.value)
        }
        guard latest != savedBMI else { return }
        savedBMI = latest
        do {
            try LatestHealthMeasurementCache.save(savedBMI, for: "bmi")
        } catch {
            Logger().error("Could not save latest BMI: \(error)")
        }
    }
}
