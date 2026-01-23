import SwiftUI
import WidgetKit
import AppIntents

@available(iOS 18, *)
struct GlucosyWidgetsControl: ControlWidget {
    private static let kind = "dev.topscrech.Glucosy.Glucosy Widgets"
    
    var body: some ControlWidgetConfiguration {
        AppIntentControlConfiguration(kind: Self.kind, provider: Provider()) { value in
            ControlWidgetToggle(
                "Start Timer",
                isOn: value.isRunning,
                action: StartTimerIntent(value.name)
            ) { isRunning in
                Label(isRunning ? "On" : "Off", systemImage: "timer")
            }
        }
        .displayName("Timer")
        .description("A an example control that runs a timer")
    }
}

@available(iOS 18, *)
extension GlucosyWidgetsControl {
    struct Value {
        var isRunning: Bool
        var name: String
    }
    
    struct Provider: AppIntentControlValueProvider {
        func previewValue(configuration: TimerConfiguration) -> Value {
            GlucosyWidgetsControl.Value(isRunning: false, name: configuration.timerName)
        }
        
        func currentValue(configuration: TimerConfiguration) async throws -> Value {
            // Check if the timer is running
            let isRunning = true
            
            return GlucosyWidgetsControl.Value(isRunning: isRunning, name: configuration.timerName)
        }
    }
}

@available(iOS 18, *)
struct TimerConfiguration: ControlConfigurationIntent {
    static let title: LocalizedStringResource = "Timer Name Configuration"
    
    @Parameter(title: "Timer Name", default: "Timer")
    var timerName: String
}

struct StartTimerIntent: SetValueIntent {
    static let title: LocalizedStringResource = "Start a timer"
    
    @Parameter(title: "Timer Name")
    var name: String
    
    @Parameter(title: "Timer is running")
    var value: Bool
    
    init() {}
    
    init(_ name: String) {
        self.name = name
    }
    
    // Start the timer
    func perform() async throws -> some IntentResult {
        .result()
    }
}
