import AppIntents

struct ACGlucoseConfiguration: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")
    
    @Parameter(title: "Show measure time", default: true)
    var showMeasureTime: Bool
    
    @Parameter(title: "Show Unit", default: true)
    var showUnit: Bool
    
    @Parameter(title: "Action after opening the app", optionsProvider: ActionOptionsProvider())
    var action: IntentAction
    
    init() {
        self.action = .nfc
    }
    
    init(action: IntentAction) {
        self.action = action
    }
}
