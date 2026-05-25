import AppIntents

struct LogCarbsIntent: AppIntent {
    static let title: LocalizedStringResource = "Log Carbohydrates"
    static let description = IntentDescription("Log carbohydrates to Health")

    @Parameter(title: "Carbohydrates", inclusiveRange: (0.1, 1_000))
    var grams: Double

    init() {}

    init(grams: Double) {
        self.grams = grams
    }

    func perform() async throws -> some IntentResult {
        guard grams > 0 else {
            throw HealthShortcutError.invalidCarbs
        }

        let healthKit = await HealthKit()
        try await healthKit.requestShortcutAuthorization(
            for: healthKit.carbsType,
            deniedError: .carbsAuthorizationDenied
        )
        try await healthKit.writeShortcutCarbs(value: grams)

        return .result()
    }
}
