import AppIntents

struct ACGlucoseConfiguration: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")
    
    @Parameter(title: "Show measure time", default: true)
    var showMeasureTime: Bool
    
    @Parameter(title: "Show Unit", default: true)
    var showUnit: Bool
    
    @Parameter(title: "Start NFC scan after opening", default: true)
    var startNfc: Bool
}
