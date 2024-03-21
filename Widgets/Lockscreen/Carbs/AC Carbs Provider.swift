import WidgetKit

struct ACCarbsProvider: AppIntentTimelineProvider {
    private let userDefaults = UserDefaults(suiteName: "group.dev.topscrech.Health-Point")!
    
    private let date = Date()
    
    // Xcode previews
    func placeholder(in context: Context) -> CarbsEntry {
        .init(data: 69, date: date, configuration: ACCarbsConfiguration())
    }
    
    // Widget gallery
    func snapshot(
        for configuration: ACCarbsConfiguration,
        in context: Context
    ) async -> CarbsEntry {
        .init(data: 69, date: date, configuration: configuration)
    }
    
    // Timeline generation with user configuration
    func timeline(
        for configuration: ACCarbsConfiguration,
        in context: Context
    ) async -> Timeline<CarbsEntry> {
        let currentDate = Date()
        
        let entryDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        
        let carbsRecords = await HealthKit().readCarbsForToday()
        
        let sum = carbsRecords.map(\.value).reduce(0, +)
        
        var timeline: Timeline<CarbsEntry>
        let entry = CarbsEntry(
            data: sum,
            date: date,
            configuration: configuration
        )
        
        timeline = Timeline(entries: [entry], policy: .after(entryDate))
        
        return timeline
    }
}
