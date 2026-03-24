import Foundation

extension Array where Element == DoseEntry {
    var doseHistoryExportText: String {
        guard !isEmpty else {
            return ""
        }
        
        return doseHistoryExportLines.joined(separator: "\n")
    }
    
    private var doseHistoryExportLines: [String] {
        map {
            "\($0.doseHistoryExportTimestamp)\t\($0.units.formatted(.number.precision(.fractionLength(1))))\traw=\($0.rawUnits)"
        }
    }
}

extension DoseEntry {
    fileprivate var doseHistoryExportTimestamp: String {
        Self.exportFormatter.string(from: timestamp)
    }
    
    private static let exportFormatter = ISO8601DateFormatter()
}
