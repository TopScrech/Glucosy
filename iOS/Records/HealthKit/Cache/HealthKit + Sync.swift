import HealthKit
import OSLog

extension HealthKit {
    func refreshRecords(
        for type: HKQuantityType,
        fullHistory: Bool,
        ifStale: Bool,
        existing: @escaping () -> [HKQuantitySample],
        apply: @escaping ([HKQuantitySample]) -> Void
    ) async throws {
        let key = type.identifier
        let includesHistory = fullHistory || recordAnchors[key] != nil
        try await withRecordRefresh(for: type, fullHistory: includesHistory, ifStale: ifStale) { [self] in
            if includesHistory, !cachedTypes.contains(key) {
                do {
                    if let snapshot = try await recordCache.loadSampleSync(for: key) {
                        apply(uniqueSamples(snapshot.samples + existing()))
                        recordAnchors[key] = snapshot.anchor
                        cachedTypes.insert(key)
                    }
                } catch {
                    Logger().error("Could not restore health sync snapshot: \(error)")
                }
                if !cachedTypes.contains(key), let cached = try? await recordCache.loadSamples(for: key) {
                    apply(uniqueSamples(cached + existing()))
                    cachedTypes.insert(key)
                }
            }

            if includesHistory {
                guard let store else { throw HKError(.errorHealthDataUnavailable) }
                let baseline = existing()
                var anchor = recordAnchors[key]
                let result: HKAnchoredObjectQueryDescriptor<HKQuantitySample>.Result
                do {
                    result = try await anchoredChanges(for: type, anchor: anchor, store: store)
                } catch {
                    // A rejected anchor needs a new authoritative baseline, not a partial merge
                    guard anchor != nil, (error as? HKError)?.code == .errorInvalidArgument else { throw error }
                    anchor = nil
                    result = try await anchoredChanges(for: type, anchor: nil, store: store)
                }
                if anchor != nil, result.addedSamples.isEmpty, result.deletedObjects.isEmpty { return }
                let merged = HealthRecordMerge.merge(
                    existing: anchor == nil ? [] : existing(),
                    incoming: result.addedSamples,
                    deletedIDs: Set(result.deletedObjects.map(\.uuid)),
                    id: \.uuid,
                    date: \.startDate
                )
                let samples = HealthRecordMerge.preservingLocalChanges(
                    from: baseline,
                    current: existing(),
                    incoming: merged,
                    id: \.uuid,
                    date: \.startDate
                )
                // Publish before suspending so a local write during persistence is not overwritten
                apply(samples)
                // Advance the in-memory anchor only after its matching snapshot is durable
                try await recordCache.saveSampleSync(samples, anchor: result.newAnchor, refreshedAt: .now, for: key)
                recordAnchors[key] = result.newAnchor
                cachedTypes.insert(key)
            } else {
                let samples = try await refreshedSamples(for: type, existing: existing)
                apply(samples)
                await persistSamples(samples, for: type)
            }
        }
    }

    func anchoredChanges(for type: HKQuantityType, anchor: HKQueryAnchor?, store: HKHealthStore, limit: Int? = nil) async throws -> HKAnchoredObjectQueryDescriptor<HKQuantitySample>.Result {
        let descriptor = HKAnchoredObjectQueryDescriptor(
            predicates: [.quantitySample(type: type)],
            anchor: anchor,
            limit: limit
        )
        return try await descriptor.result(for: store)
    }
}
