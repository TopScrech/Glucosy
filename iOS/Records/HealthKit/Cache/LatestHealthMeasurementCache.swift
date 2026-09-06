import Foundation

nonisolated enum LatestHealthMeasurementCache {
    static let directory = URL.applicationSupportDirectory.appending(path: "LatestHealthMeasurements", directoryHint: .isDirectory)

    static func load(for key: String, directory: URL = directory) throws -> LatestHealthMeasurement? {
        let url = directory.appending(path: key)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return try JSONDecoder().decode(LatestHealthMeasurement.self, from: Data(contentsOf: url))
    }

    static func save(_ measurement: LatestHealthMeasurement?, for key: String, directory: URL = directory) throws {
        var url = directory.appending(path: key)
        guard let measurement else {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            return
        }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try JSONEncoder().encode(measurement).write(to: url, options: [.atomic, .completeFileProtection])
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try url.setResourceValues(values)
    }
}
