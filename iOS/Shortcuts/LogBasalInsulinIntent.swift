import AppIntents

struct LogBasalInsulinIntent: AppIntent {
    static let title: LocalizedStringResource = "Log Basal Insulin"
    static let description = IntentDescription("Log a basal insulin dose to Health")

    @Parameter(title: "Units of Insulin", inclusiveRange: (0.1, 100))
    var units: Double

    init() {}

    init(units: Double) {
        self.units = units
    }

    func perform() async throws -> some IntentResult {
        try await logInsulin(type: .basal)
    }

    private func logInsulin(type: InsulinType) async throws -> some IntentResult {
        guard units > 0 else {
            throw HealthShortcutError.invalidInsulin
        }

        let healthKit = await HealthKit()
        try await healthKit.requestShortcutAuthorization()
        _ = try await healthKit.writeInsulin(value: units, type: type)

        return .result()
    }
}
