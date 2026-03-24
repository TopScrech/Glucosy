import Foundation
import Observation

@Observable
final class PenReaderVM {
    var status: ReaderStatus = .idle
    var reading: PenReading?
    var errorMessage: String?
    var logs: [ReaderLogEntry] = []
    var readerOptions = ReaderOptions()
    
    private let service = NovoPenReaderService()
    private let logStore = ReaderLogStore()
    
    var isWorking: Bool {
        status == .scanning || status == .loadingSample
    }
    
    var statusTitle: String {
        switch status {
        case .idle: String(localized: "Ready to scan")
        case .scanning: String(localized: "Scanning pen")
        case .loadingSample: String(localized: "Loading sample trace")
        case .finished: String(localized: "Read completed")
        case .failed: String(localized: "Read failed")
        }
    }
    
    var statusMessage: String {
        switch status {
        case .idle: String(localized: "Use a real NFC scan on device or load the bundled trace in simulator")
        case .scanning: String(localized: "Keep the NovoPen near the top edge of the iPhone until the read finishes")
        case .loadingSample: String(localized: "Replaying the upstream trace file bundled with this app")
        case .finished: String(localized: "Model, serial number, and dose history were read successfully")
        case .failed: errorMessage ?? String(localized: "An unknown error occurred")
        }
    }
    
    var hasReading: Bool {
        reading != nil
    }
    
    var doses: [DoseEntry] {
        reading?.doses ?? []
    }
    
    func visibleDoses(using airshotFilter: AirshotFilter) -> [DoseEntry] {
        guard let maxUnits = airshotFilter.maxUnits else {
            return doses
        }
        
        return doses.filter { $0.units > maxUnits }
    }
    
    func doseHistoryExportText(using airshotFilter: AirshotFilter) -> String {
        visibleDoses(using: airshotFilter).doseHistoryExportText
    }
    
    func doseMatches(using insulinRecords: [Insulin], airshotFilter: AirshotFilter) -> [DoseHealthKitMatch] {
        DoseHealthKitMatcher(insulinRecords: insulinRecords).match(for: visibleDoses(using: airshotFilter))
    }
    
    var logText: String {
        logs.map(\.formattedLine).joined(separator: "\n")
    }
    
    var visibleLogText: String {
        logs.suffix(80).map(\.formattedLine).joined(separator: "\n")
    }
    
    var hasSavedLog: Bool {
        !logStore.load().trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var logFileURL: URL {
        logStore.url
    }
    
    init() {
        let savedLog = logStore.load().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !savedLog.isEmpty {
            logs = savedLog
                .components(separatedBy: .newlines)
                .filter { !$0.isEmpty }
                .map { ReaderLogEntry(message: "Recovered: \($0)") }
        }
    }
    
    func startScan() {
        Task {
            await beginRead(from: .liveNFC)
        }
    }
    
    func loadSampleTrace() {
        Task {
            await beginRead(from: .sampleTrace)
        }
    }
    
    private func beginRead(from source: NovoPenReadSource) async {
        guard !isWorking else {
            return
        }
        
        errorMessage = nil
        reading = nil
        logs = []
        logStore.reset()
        status = source == .liveNFC ? .scanning : .loadingSample
        
        do {
            let options = readerOptions
            appendLog(options.receivesFullHistory ? "Full history mode enabled" : "Full history mode disabled")
            
            let reading = try await service.readPen(using: source, options: options) { message in
                Task { @MainActor in
                    self.appendLog(message)
                }
            }
            self.reading = reading
            status = .finished
        } catch {
            status = .failed
            errorMessage = error.localizedDescription
            appendLog("Failed [\(String(reflecting: type(of: error)))]: \(error.localizedDescription)")
        }
    }
    
    private func appendLog(_ message: String) {
        let entry = ReaderLogEntry(message: message)
        logs.append(entry)
        logStore.append(entry.formattedLine)
    }
}
