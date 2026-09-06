import Foundation

@main
struct LatestHealthMeasurementCacheTests {
    static func main() throws {
        let directory = URL.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
        defer { try? FileManager.default.removeItem(at: directory) }
        let weight = LatestHealthMeasurement(id: UUID(), date: Date(timeIntervalSince1970: 100), value: 72.5)
        let bmi = LatestHealthMeasurement(id: UUID(), date: Date(timeIntervalSince1970: 200), value: 23.1)
        try LatestHealthMeasurementCache.save(weight, for: "weight", directory: directory)
        try LatestHealthMeasurementCache.save(bmi, for: "bmi", directory: directory)
        let restoredWeight = try LatestHealthMeasurementCache.load(for: "weight", directory: directory)
        let restoredBMI = try LatestHealthMeasurementCache.load(for: "bmi", directory: directory)
        precondition(restoredWeight == weight, "Old weight must be available synchronously from disk without sample history")
        precondition(restoredBMI == bmi, "Old BMI must be available synchronously from disk without sample history")
        let replacement = LatestHealthMeasurement(id: UUID(), date: Date(timeIntervalSince1970: 300), value: 71)
        try LatestHealthMeasurementCache.save(replacement, for: "weight", directory: directory)
        let updated = try LatestHealthMeasurementCache.load(for: "weight", directory: directory)
        precondition(updated == replacement)
        try LatestHealthMeasurementCache.save(nil, for: "weight", directory: directory)
        let deleted = try LatestHealthMeasurementCache.load(for: "weight", directory: directory)
        precondition(deleted == nil, "Deleted measurements must not reappear after restart")
        print("Latest measurement disk persistence tests passed")
    }
}
