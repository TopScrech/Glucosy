import AppIntents

struct ACCarbsConfiguration: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")
    
    @Parameter(title: "Show Date", default: true)
    var showDate: Bool
    
    @Parameter(title: "Show Unit", default: true)
    var showUnit: Bool
    
    @Parameter(title: "Start NFC scan after opening", default: true)
    var startNfc: Bool
}
