import HealthKit

actor HealthRecordCache {
    private let directory = URL.applicationSupportDirectory.appending(path: "HealthRecords", directoryHint: .isDirectory)

    func loadSamples(for key: String) throws -> [HKQuantitySample]? {
        guard let data = try load(key) else { return nil }
        return try NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClass: HKQuantitySample.self, from: data)
    }

    func saveSamples(_ samples: [HKQuantitySample], for key: String) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: samples, requiringSecureCoding: true)
        try save(data, key: key)
    }

    func loadEnergy(for key: String) throws -> [EnergyDay]? {
        guard let data = try load(key) else { return nil }
        return try JSONDecoder().decode([EnergyDay].self, from: data)
    }

    func saveEnergy(_ days: [EnergyDay], for key: String) throws {
        try save(JSONEncoder().encode(days), key: key)
    }

    private func load(_ key: String) throws -> Data? {
        let url = directory.appending(path: key)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return try Data(contentsOf: url)
    }

    private func save(_ data: Data, key: String) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        var url = directory.appending(path: key)
        try data.write(to: url, options: [.atomic, .completeFileProtection])
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try url.setResourceValues(values)
    }
}
