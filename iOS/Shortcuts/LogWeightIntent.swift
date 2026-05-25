import AppIntents

struct LogWeightIntent: AppIntent {
    static let title: LocalizedStringResource = "Log Weight"
    static let description = IntentDescription("Log weight to Health")

    @Parameter(title: "Weight")
    var kilograms: Double

    init() {}

    init(kilograms: Double) {
        self.kilograms = kilograms
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard kilograms > 0 else {
            throw HealthShortcutError.invalidWeight
        }

        let healthKit = await HealthKit()
        try await healthKit.requestShortcutAuthorization()
        try await healthKit.writeShortcutWeight(value: kilograms)

        return .result(
            dialog: "Logged \(kilograms.formatted(.number.precision(.fractionLength(1)))) kilograms of weight"
        )
    }
}
