import Foundation
import Observation

@Observable
final class LogDietaryEnergyVM {
    var amount = ""
    var date = Date.now
    var isSaving = false
    var errorMessage: String?

    init(initialAmount: Double? = nil) {
        if let initialAmount, initialAmount.isFinite, initialAmount > 0 {
            amount = initialAmount.formatted(.number.grouping(.never))
        }
    }

    var value: Double? {
        guard let value = Double(amount.replacing(",", with: ".")), value.isFinite, value > 0 else {
            return nil
        }
        return value
    }

    var canSave: Bool {
        value != nil && !isSaving
    }

    func save(action: (Double, Date) async throws -> Void) async -> Bool {
        guard canSave, let value else { return false }
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            try await action(value, date)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
