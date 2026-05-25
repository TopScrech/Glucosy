extension HealthKit {
    func requestShortcutAuthorization() async throws {
        let isAuthorized = await withCheckedContinuation { continuation in
            authorize {
                continuation.resume(returning: $0)
            }
        }

        guard isAuthorized else {
            throw InsulinShortcutError.authorizationDenied
        }
    }
}
