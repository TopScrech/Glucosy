import AppIntents

@available(iOS 18.0, *)
struct OpenNovoPenScanIntent: AppIntent {
    static let title: LocalizedStringResource = "Scan NovoPen"
    static let description = IntentDescription("Open Glucosy and start a NovoPen NFC scan")
    
    func perform() async throws -> IntentResultContainer<Never, OpenURLIntent, Never, Never> {
        guard let scanURL = URL(string: "glucosy://startNovoPenScan") else {
            throw CancellationError()
        }
        
        return .result(opensIntent: OpenURLIntent(scanURL))
    }
}
