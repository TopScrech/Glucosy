import HealthKit
import OSLog

extension HealthKit {
    func requestShortcutAuthorization(
        for sampleType: HKSampleType,
        deniedError: HealthShortcutError
    ) async throws {
        let isAuthorized = await withCheckedContinuation { continuation in
            authorize {
                continuation.resume(returning: $0)
            }
        }

        guard isAuthorized,
              store?.authorizationStatus(for: sampleType) == .sharingAuthorized
        else {
            throw deniedError
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

        try await saveShortcutSample(sample, deniedError: .carbsAuthorizationDenied, logName: "carbs")
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

        try await saveShortcutSample(sample, deniedError: .weightAuthorizationDenied, logName: "weight")
        weightRecords.insert(Weight(value: value, sample: sample), at: 0)
    }

    private func saveShortcutSample(
        _ sample: HKQuantitySample,
        deniedError: HealthShortcutError,
        logName: String
    ) async throws {
        guard let store else {
            throw HealthShortcutError.healthKitUnavailable
        }

        guard store.authorizationStatus(for: sample.quantityType) == .sharingAuthorized else {
            throw deniedError
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            store.save(sample) { success, error in
                if let error {
                    Logger().error("HealthKit: error while saving \(logName): \(error)")
                    continuation.resume(throwing: deniedError)
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
