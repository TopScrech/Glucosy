import Foundation
import HealthKit
import Testing
@testable import Records

struct HealthSyncTests {
    @Test func freshnessRequiresSuccessfulMatchingScope() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        var state = HealthRefreshState()
        #expect(!state.isFresh(fullHistory: false, now: now))
        state.recordSuccess(fullHistory: false, at: now)
        #expect(state.isFresh(fullHistory: false, now: now))
        #expect(!state.isFresh(fullHistory: true, now: now))
        state.recordSuccess(fullHistory: true, at: now)
        #expect(state.isFresh(fullHistory: true, now: now.addingTimeInterval(59)))
        #expect(!state.isFresh(fullHistory: true, now: now.addingTimeInterval(60)))
        #expect(!state.isFresh(fullHistory: true, now: now.addingTimeInterval(-1)))
    }

    @Test func recentRefreshDoesNotExtendHistoryFreshness() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        var state = HealthRefreshState()
        state.recordSuccess(fullHistory: true, at: now)
        state.recordSuccess(fullHistory: false, at: now.addingTimeInterval(50))
        #expect(!state.isFresh(fullHistory: true, now: now.addingTimeInterval(70)))
        #expect(state.isFresh(fullHistory: false, now: now.addingTimeInterval(70)))
    }

    @Test func syncPreservesConcurrentLocalWritesAndDeletions() {
        let removed = sample()
        let added = sample()
        let remote = sample()
        let merged = HealthRecordMerge.preservingLocalChanges(
            from: [removed], current: [added], incoming: [removed, remote], id: \.uuid, date: \.startDate
        )
        #expect(Set(merged.map(\.uuid)) == [added.uuid, remote.uuid])
        let replay = HealthRecordMerge.merge(existing: merged, incoming: [remote, added], deletedIDs: [removed.uuid], id: \.uuid, date: \.startDate)
        #expect(Set(replay.map(\.uuid)) == Set(merged.map(\.uuid)))
    }

    @Test func sampleSnapshotKeepsAnchorAndPayloadTogether() async throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let cache = HealthRecordCache(directory: directory)
        let record = sample()
        let anchor = HKQueryAnchor(fromValue: 42)
        let now = Date.now
        try await cache.saveSampleSync([record], anchor: anchor, refreshedAt: now, for: "test")
        let restored = try #require(await cache.loadSampleSync(for: "test"))
        #expect(restored.samples.map(\.uuid) == [record.uuid])
        #expect(restored.anchor.isEqual(anchor))
        #expect(restored.refreshedAt == now)
        // A recent-only cache write must not replace the full snapshot or its anchor
        try await cache.saveStartupSamples([], for: "test")
        let afterRecentWrite = try #require(await cache.loadSampleSync(for: "test"))
        #expect(afterRecentWrite.samples.map(\.uuid) == [record.uuid])
        #expect(afterRecentWrite.anchor.isEqual(anchor))
    }

    @Test func failedSaveDoesNotAdvancePersistedAnchor() async throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let cache = HealthRecordCache(directory: directory)
        let record = sample()
        let anchor = HKQueryAnchor(fromValue: 1)
        try await cache.saveSampleSync([record], anchor: anchor, refreshedAt: .now, for: "test")
        let startup = directory.appending(path: "test-startup")
        try FileManager.default.removeItem(at: startup)
        try FileManager.default.createDirectory(at: startup, withIntermediateDirectories: true)
        await #expect(throws: (any Error).self) {
            try await cache.saveSampleSync([], anchor: HKQueryAnchor(fromValue: 2), refreshedAt: .now, for: "test")
        }
        let restored = try #require(await cache.loadSampleSync(for: "test"))
        #expect(restored.samples.map(\.uuid) == [record.uuid])
        #expect(restored.anchor.isEqual(anchor))
    }

    @Test func corruptSnapshotCannotSupplyAnAnchor() async throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try Data("broken".utf8).write(to: directory.appending(path: "test-sync-v1"))
        let cache = HealthRecordCache(directory: directory)
        await #expect(throws: (any Error).self) { try await cache.loadSampleSync(for: "test") }
        #expect(try await cache.loadSampleSync(for: "missing") == nil)
    }

    @Test func energySnapshotRetainsDailyTotalsAndAnchor() async throws {
        let directory = temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let cache = HealthRecordCache(directory: directory)
        let day = EnergyDay(date: .now, value: 300)
        let anchor = HKQueryAnchor(fromValue: 3)
        try await cache.saveEnergySync([day], anchor: anchor, refreshedAt: .now, for: "energy-days")
        let restored = try #require(await cache.loadEnergySync(for: "energy-days"))
        #expect(restored.days.first?.value == 300)
        #expect(restored.days.first?.date == day.date)
        #expect(restored.anchor.isEqual(anchor))
    }

    private func sample() -> HKQuantitySample {
        HKQuantitySample(type: HKQuantityType(.dietaryCarbohydrates), quantity: HKQuantity(unit: .gram(), doubleValue: 1), start: .now, end: .now)
    }

    private func temporaryDirectory() -> URL {
        FileManager.default.temporaryDirectory.appending(path: "GlucosySyncTests-" + UUID().uuidString, directoryHint: .isDirectory)
    }
}
