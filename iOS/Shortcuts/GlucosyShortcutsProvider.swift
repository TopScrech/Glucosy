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
    }
}
