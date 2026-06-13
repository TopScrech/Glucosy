import HealthKit
import OSLog
import WidgetKit

struct BasalReminderProvider: TimelineProvider {
    func placeholder(in context: Context) -> BasalReminderEntry {
        BasalReminderEntry(date: .now, basalCount: 0, isSkippedToday: false, errorDescription: nil)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (BasalReminderEntry) -> Void) {
        if context.isPreview {
            completion(BasalReminderEntry(
                date: .now,
                basalCount: 0,
                isSkippedToday: false,
                errorDescription: nil
            ))
            return
        }
        
        Task {
            completion(await basalReminderEntry())
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<BasalReminderEntry>) -> Void) {
        Task {
            let entry = await basalReminderEntry()
            let refreshDate = Calendar.current.date(byAdding: .hour, value: 1, to: entry.date) ?? entry.date.addingTimeInterval(60 * 60)
            
            completion(Timeline(entries: [entry], policy: .after(refreshDate)))
        }
    }
}

extension BasalReminderProvider {
    func basalReminderEntry() async -> BasalReminderEntry {
        do {
            let basalCount = try await todayBasalCount()
            
            return BasalReminderEntry(
                date: .now,
                basalCount: basalCount,
                isSkippedToday: BasalReminderAppStorage.isSkippedToday(),
                errorDescription: nil
            )
        } catch {
            Logger().error("Basal reminder widget failed to load HealthKit records: \(error)")
            
            return BasalReminderEntry(
                date: .now,
                basalCount: 0,
                isSkippedToday: BasalReminderAppStorage.isSkippedToday(),
                errorDescription: "Unable to Load"
            )
        }
    }
    
    private func todayBasalCount() async throws -> Int {
        guard HKHealthStore.isHealthDataAvailable() else {
            return 0
        }
        
        let store = HKHealthStore()
        guard let insulinType = HKQuantityType.quantityType(forIdentifier: .insulinDelivery) else {
            return 0
        }
        
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let basalPredicate = HKQuery.predicateForObjects(
            withMetadataKey: HKMetadataKeyInsulinDeliveryReason,
            operatorType: .equalTo,
            value: HKInsulinDeliveryReason.basal.rawValue
        )
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, basalPredicate])
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: insulinType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, results, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                continuation.resume(returning: results?.count ?? 0)
            }
            
            store.execute(query)
        }
    }
}
