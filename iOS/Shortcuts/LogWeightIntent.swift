import AppIntents

struct LogWeightIntent: AppIntent {
    static let title: LocalizedStringResource = "Log Weight"
    static let description = IntentDescription("Log weight to Health")

    @Parameter(title: "Weight", inclusiveRange: (0.1, 1_000))
    var kilograms: Double

    init() {}

    init(kilograms: Double) {
        self.kilograms = kilograms
    }

    func perform() async throws -> some IntentResult {
        guard kilograms > 0 else {
            throw HealthShortcutError.invalidWeight
        }

        let healthKit = await HealthKit()
        try await healthKit.requestShortcutAuthorization(
            for: healthKit.bodyMassType,
            deniedError: .weightAuthorizationDenied
        )
        try await healthKit.writeShortcutWeight(value: kilograms)

        return .result()
    }
}
