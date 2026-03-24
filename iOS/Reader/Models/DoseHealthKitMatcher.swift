import Foundation

struct DoseHealthKitMatcher {
    private let insulinRecords: [Insulin]
    private let maxTimeInterval: TimeInterval = 10 * 60
    private let maxUnitDifference = 0.05
    
    init(insulinRecords: [Insulin]) {
        self.insulinRecords = insulinRecords
    }
    
    func match(for doses: [DoseEntry]) -> [DoseHealthKitMatch] {
        let sortedRecords = insulinRecords.sorted { $0.date < $1.date }
        var usedSampleIDs = Set<UUID>()
        
        return doses.map { dose in
            guard let sampleID = bestMatchSampleID(for: dose, in: sortedRecords, usedSampleIDs: usedSampleIDs) else {
                return .missing
            }
            
            usedSampleIDs.insert(sampleID)
            return .matched
        }
    }
    
    private func bestMatchSampleID(
        for dose: DoseEntry,
        in insulinRecords: [Insulin],
        usedSampleIDs: Set<UUID>
    ) -> UUID? {
        insulinRecords
            .filter { !usedSampleIDs.contains($0.sample.uuid) }
            .filter { abs($0.value - dose.units) <= maxUnitDifference }
            .filter { abs($0.date.timeIntervalSince(dose.timestamp)) <= maxTimeInterval }
            .min { lhs, rhs in
                abs(lhs.date.timeIntervalSince(dose.timestamp)) < abs(rhs.date.timeIntervalSince(dose.timestamp))
            }?
            .sample
            .uuid
    }
}
