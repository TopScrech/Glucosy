import HealthKit
import OSLog

extension HealthKit {
    func requestShortcutAuthorization() async throws {
        let isAuthorized = await withCheckedContinuation { continuation in
            authorize {
                continuation.resume(returning: $0)
            }
        }

        guard isAuthorized else {
            throw HealthShortcutError.authorizationDenied
        }
    }

    func writeShortcutCarbs(value: Double, date: Date = .now) async throws {
        let sample = HKQuantitySample(
            type: carbsType,
            quantity: .init(unit: .gram(), doubleValue: value),
            start: date,
            end: date,
            metadata: nil
        )

        try await saveShortcutSample(sample, logName: "carbs")
        carbsRecords.insert(Carbs(value: value, sample: sample), at: 0)
    }

    func writeShortcutWeight(value: Double, date: Date = .now) async throws {
        let sample = HKQuantitySample(
            type: bodyMassType,
            quantity: .init(unit: weightUnit, doubleValue: value),
            start: date,
            end: date,
            metadata: nil
        )

        try await saveShortcutSample(sample, logName: "weight")
        weightRecords.insert(Weight(value: value, sample: sample), at: 0)
    }

    private func saveShortcutSample(_ sample: HKQuantitySample, logName: String) async throws {
        guard let store else {
            throw HealthShortcutError.healthKitUnavailable
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            store.save(sample) { success, error in
                if let error {
                    Logger().error("HealthKit: error while saving \(logName): \(error)")
                    continuation.resume(throwing: error)
                    return
                }

                guard success else {
                    Logger().warning("HealthKit: \(logName) save returned false")
                    continuation.resume(throwing: HealthShortcutError.healthKitUnavailable)
                    return
                }

                continuation.resume(returning: ())
            }
        }
    }
}
