import AppIntents

struct ACGlucoseConfiguration: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")
    
    @Parameter(title: "Show measure time", default: true)
    var showMeasureTime: Bool
    
    @Parameter(title: "Show Unit", default: true)
    var showUnit: Bool
    
    @Parameter(
        title: "Glucose measurement reminder",
        description: "Displays a button to initiate a new glucose measurement if more than 2 hours have passed since the last measurement. Regardless of the action chosen below, it will always start scanning the NFC tag.",
        default: true
    )
    var glucoseMeasurementReminder: Bool
    
    @Parameter(title: "Action after opening the app", optionsProvider: ActionOptionsProvider())
    var action: IntentAction
    
    init() {
        self.action = .nfc
    }
    
    init(action: IntentAction) {
        self.action = action
    }
}
