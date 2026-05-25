import AppIntents

struct GlucosyShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenNovoPenScanIntent(),
            phrases: [
                "Scan NovoPen in \(.applicationName)",
                "Start NovoPen scan in \(.applicationName)",
                "Open NovoPen scanner in \(.applicationName)"
            ],
            shortTitle: "Scan NovoPen",
            systemImageName: "wave.3.right"
        )
        
        AppShortcut(
            intent: LogBolusInsulinIntent(),
            phrases: [
                "Log bolus insulin in \(.applicationName)",
                "Add bolus insulin in \(.applicationName)",
                "Record bolus insulin in \(.applicationName)"
            ],
            shortTitle: "Log Bolus",
            systemImageName: "syringe"
        )
        
        AppShortcut(
            intent: LogBasalInsulinIntent(),
            phrases: [
                "Log basal insulin in \(.applicationName)",
                "Add basal insulin in \(.applicationName)",
                "Record basal insulin in \(.applicationName)"
            ],
            shortTitle: "Log Basal",
            systemImageName: "syringe.fill"
        )
        
        AppShortcut(
            intent: LogCarbsIntent(),
            phrases: [
                "Log carbohydrates in \(.applicationName)",
                "Add carbs in \(.applicationName)",
                "Record carbohydrates in \(.applicationName)"
            ],
            shortTitle: "Log Carbs",
            systemImageName: "fork.knife"
        )
        
        AppShortcut(
            intent: LogWeightIntent(),
            phrases: [
                "Log weight in \(.applicationName)",
                "Add weight in \(.applicationName)",
                "Record weight in \(.applicationName)"
            ],
            shortTitle: "Log Weight",
            systemImageName: "scalemass"
        )
    }
}
