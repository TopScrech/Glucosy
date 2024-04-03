import AppIntents

struct ActionOptionsProvider: DynamicOptionsProvider {
    func results() async throws -> [IntentAction] {
        IntentAction.allCases
    }
}

struct ACCarbsConfiguration: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")
    
    @Parameter(title: "Show Date", default: true)
    var showDate: Bool
    
    @Parameter(title: "Show Unit", default: true)
    var showUnit: Bool
    
    @Parameter(title: "Action after opening the app", optionsProvider: ActionOptionsProvider())
    var action: IntentAction
    
    init() {
        self.action = .newRecord
    }
    
    init(action: IntentAction) {
        self.action = action
    }
}

enum IntentAction: String, CaseIterable, AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = .init(name: "Action")
    
    case nfc =       "action/nfc",
         newRecord = "action/new_record",
         noAction
    
    var displayRepresentation: DisplayRepresentation {
        switch self {
        case .nfc:       .init(title: "New Scan")
        case .newRecord: .init(title: "New Record")
        case .noAction:  .init(title: "No action")
        }
    }
    
    static var caseDisplayRepresentations: [IntentAction: DisplayRepresentation] = [
        .nfc:       .init(stringLiteral: "New Scan"),
        .newRecord: .init(stringLiteral: "New Record"),
        .noAction:  .init(stringLiteral: "No Action")
    ]
    
    var title: String {
        switch self {
        case .nfc:       "New Scan"
        case .newRecord: "New Record"
        case .noAction:  "No Action"
        }
    }
}
