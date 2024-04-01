import AppIntents

struct ChartConfiguration: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")
    
    @Parameter(title: "Action after opening the app", optionsProvider: ActionOptionsProvider())
    var action: IntentAction
    
    init() {
        self.action = .nfc
    }
    
    init(action: IntentAction) {
        self.action = action
    }
}
