import SwiftUI
import HealthKit
import AppIntents
import WidgetKit

struct ChartProvider: AppIntentTimelineProvider {
    private let userDefaults = UserDefaults(suiteName: "group.dev.topscrech.Health-Point")!
    
    private var predicate: NSPredicate {
        let endDate = Date()
        let startDate = Calendar.current.date(
            byAdding: .day,
            value: -1,
            to: Date()
        )
        
        return HKQuery.predicateForSamples(
            withStart: startDate,
            end:       endDate,
            options:   .strictStartDate
        )
    }
    
    private var unit: String {
        if userDefaults.bool(forKey: "displayingMillimoles") {
            "mmol/L"
        } else {
            "mg/dL"
        }
    }
    
    // Xcode previews
    func placeholder(in context: Context) -> ChartEntry {
        return ChartEntry(
            date: Date(),
            glucose: [],
            unit: unit,
            configuration: ChartConfiguration()
        )
    }
    
    // Widget gallery
    func snapshot(
        for configuration: ChartConfiguration,
        in context: Context
    ) async -> ChartEntry {
        let glucose = await HealthKit().readGlucose(predicate: predicate)
        
        return ChartEntry(
            date: Date(),
            glucose: glucose,
            unit: unit,
            configuration: ChartConfiguration()
        )
    }
    
    // Timeline generation with user configuration
    func timeline(
        for configuration: ChartConfiguration,
        in context: Context
    ) async -> Timeline<ChartEntry> {
        let currentDate = Date()
        
        let entryDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        
        let glucose = await HealthKit().readGlucose(predicate: predicate)
        
        let entry = ChartEntry(
            date: Date(),
            glucose: glucose,
            unit: unit,
            configuration: ChartConfiguration()
        )
        
        let timeline = Timeline(entries: [entry], policy: .after(entryDate))
        
        return timeline
    }
}
