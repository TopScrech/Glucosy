import WidgetKit
import HealthKit
import OSLog

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: .now, weightEntries: Self.previewEntries, errorDescription: nil)
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        if context.isPreview {
            return SimpleEntry(date: .now, weightEntries: Self.previewEntries, errorDescription: nil)
        }
        
        return await weightEntry()
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let entry = await weightEntry()
        let refreshDate = Calendar.current.date(byAdding: .hour, value: 1, to: entry.date) ?? entry.date.addingTimeInterval(60 * 60)
        
        return Timeline(entries: [entry], policy: .after(refreshDate))
    }
    
    //    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
    //        // Generate a list containing the contexts this widget is relevant in
    //    }
}

extension Provider {
    static var previewEntries: [WeightWidgetEntry] {
        [
            WeightWidgetEntry(id: UUID(), date: .now.addingTimeInterval(-9 * 86_400), value: 84.2),
            WeightWidgetEntry(id: UUID(), date: .now.addingTimeInterval(-8 * 86_400), value: 83.9),
            WeightWidgetEntry(id: UUID(), date: .now.addingTimeInterval(-7 * 86_400), value: 83.5),
            WeightWidgetEntry(id: UUID(), date: .now.addingTimeInterval(-6 * 86_400), value: 83.8),
            WeightWidgetEntry(id: UUID(), date: .now.addingTimeInterval(-5 * 86_400), value: 83.1),
            WeightWidgetEntry(id: UUID(), date: .now.addingTimeInterval(-4 * 86_400), value: 82.8),
            WeightWidgetEntry(id: UUID(), date: .now.addingTimeInterval(-3 * 86_400), value: 82.6),
            WeightWidgetEntry(id: UUID(), date: .now.addingTimeInterval(-2 * 86_400), value: 82.4),
            WeightWidgetEntry(id: UUID(), date: .now.addingTimeInterval(-86_400), value: 82.7),
            WeightWidgetEntry(id: UUID(), date: .now, value: 82.1)
        ]
    }
    
    func weightEntry() async -> SimpleEntry {
        do {
            let entries = try await loadWeightEntries()
            return SimpleEntry(date: .now, weightEntries: entries, errorDescription: nil)
        } catch {
            Logger().error("Weight widget failed to load HealthKit records: \(error)")
            return SimpleEntry(date: .now, weightEntries: [], errorDescription: "Unable to Load")
        }
    }
    
    func loadWeightEntries() async throws -> [WeightWidgetEntry] {
        guard HKHealthStore.isHealthDataAvailable() else {
            return []
        }
        
        let store = HKHealthStore()
        guard let bodyMassType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            return []
        }
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: bodyMassType,
                predicate: nil,
                limit: 10,
                sortDescriptors: [sortDescriptor]
            ) { _, results, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let samples = results as? [HKQuantitySample] ?? []
                let entries = samples
                    .map {
                        WeightWidgetEntry(
                            id: $0.uuid,
                            date: $0.startDate,
                            value: $0.quantity.doubleValue(for: .gramUnit(with: .kilo))
                        )
                    }
                    .sorted { $0.date < $1.date }
                
                continuation.resume(returning: entries)
            }
            
            store.execute(query)
        }
    }
}
