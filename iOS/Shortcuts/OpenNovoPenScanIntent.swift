import AppIntents

struct OpenNovoPenScanIntent: ForegroundContinuableIntent {
    static let title: LocalizedStringResource = "Scan NovoPen"
    static let description = IntentDescription("Open Glucosy and start a NovoPen NFC scan")

    func perform() async throws -> some IntentResult {
        try await requestToContinueInForeground {
            AppRouter.shared.request(.startNovoPenScan)
        }

        return .result()
    }
}
