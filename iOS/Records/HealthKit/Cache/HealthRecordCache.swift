import HealthKit
import OSLog

actor HealthRecordCache {
    private nonisolated static let defaultDirectory = URL.applicationSupportDirectory.appending(path: "HealthRecords", directoryHint: .isDirectory)

    private let directory: URL

    init(directory: URL = HealthRecordCache.defaultDirectory) {
        self.directory = directory
    }

    func loadSampleSync(for key: String) throws -> HealthSampleSyncState? {
        guard let data = try load(key + "-sync-v1") else { return nil }
        let snapshot = try JSONDecoder().decode(HealthSyncSnapshot<Data>.self, from: data)
        guard let samples = try NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClass: HKQuantitySample.self, from: snapshot.payload),
              let anchor = try NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: snapshot.anchor) else {
            throw CocoaError(.coderReadCorrupt)
        }
        return HealthSampleSyncState(samples: samples, anchor: anchor, refreshedAt: snapshot.refreshedAt)
    }

    func saveSampleSync(_ samples: [HKQuantitySample], anchor: HKQueryAnchor, refreshedAt: Date, for key: String) throws {
        let snapshot = HealthSyncSnapshot(
            payload: try NSKeyedArchiver.archivedData(withRootObject: samples, requiringSecureCoding: true),
            anchor: try NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true),
            refreshedAt: refreshedAt
        )
        try saveStartupSamples(samples, for: key)
        try save(JSONEncoder().encode(snapshot), key: key + "-sync-v1")
    }

    func loadEnergySync(for key: String) throws -> HealthEnergySyncState? {
        guard let data = try load(key + "-sync-v1") else { return nil }
        let snapshot = try JSONDecoder().decode(HealthSyncSnapshot<[EnergyDay]>.self, from: data)
        guard let anchor = try NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: snapshot.anchor) else {
            throw CocoaError(.coderReadCorrupt)
        }
        return HealthEnergySyncState(days: snapshot.payload, anchor: anchor, refreshedAt: snapshot.refreshedAt)
    }

    func saveEnergySync(_ days: [EnergyDay], anchor: HKQueryAnchor, refreshedAt: Date, for key: String) throws {
        let snapshot = HealthSyncSnapshot(
            payload: days,
            anchor: try NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true),
            refreshedAt: refreshedAt
        )
        try saveEnergy(days, for: key)
        try save(JSONEncoder().encode(snapshot), key: key + "-sync-v1")
    }

    func loadSamples(for key: String) throws -> [HKQuantitySample]? {
        guard let data = try load(key) else { return nil }
        let samples = try NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClass: HKQuantitySample.self, from: data)
        return samples
    }

    func saveSamples(_ samples: [HKQuantitySample], for key: String) throws {
        try saveStartupSamples(samples, for: key)
        let data = try NSKeyedArchiver.archivedData(withRootObject: samples, requiringSecureCoding: true)
        try save(data, key: key)
    }

    func loadEnergy(for key: String) throws -> [EnergyDay]? {
        guard let data = try load(key) else { return nil }
        return try JSONDecoder().decode([EnergyDay].self, from: data)
    }

    func saveEnergy(_ days: [EnergyDay], for key: String) throws {
        let startupDays = days.filter { $0.date >= Self.startupCutoff }
        try save(JSONEncoder().encode(startupDays), key: key + "-startup")
        try save(JSONEncoder().encode(days), key: key)
    }

    nonisolated static func loadStartupSamples(for key: String) throws -> [HKQuantitySample]? {
        var url = defaultDirectory.appending(path: key + "-startup")
        if !FileManager.default.fileExists(atPath: url.path),
           key == HKQuantityTypeIdentifier.bodyMass.rawValue || key == HKQuantityTypeIdentifier.bodyMassIndex.rawValue {
            // Migrate existing weight and BMI history without waiting for unrelated caches
            url = defaultDirectory.appending(path: key)
        }
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return try NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClass: HKQuantitySample.self, from: Data(contentsOf: url))
    }

    nonisolated static func loadStartupEnergy(for key: String) throws -> [EnergyDay]? {
        let startupURL = defaultDirectory.appending(path: key + "-startup")
        // Existing daily totals are small enough to use when upgrading from the original cache
        let url = FileManager.default.fileExists(atPath: startupURL.path) ? startupURL : defaultDirectory.appending(path: key)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return try JSONDecoder().decode([EnergyDay].self, from: Data(contentsOf: url))
    }

    private nonisolated static var startupCutoff: Date {
        Calendar.current.startOfDay(for: .now).addingTimeInterval(-24 * 60 * 60)
    }

    func saveStartupSamples(_ samples: [HKQuantitySample], for key: String) throws {
        // Include today's totals and recent rows, plus the latest weight or BMI even when older
        let startupSamples = HealthStartupRecords.select(from: samples, since: Self.startupCutoff, date: \.startDate)
        let data = try NSKeyedArchiver.archivedData(withRootObject: startupSamples, requiringSecureCoding: true)
        try save(data, key: key + "-startup")
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
