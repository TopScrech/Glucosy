import ScrechKit
import WidgetKit

struct HomeView: View {
    @Environment(AppState.self) private var app: AppState
    @Environment(Log.self)      private var log: Log
    @Environment(History.self)  private var history: History
    @Environment(Settings.self) private var settings: Settings
    
    var body: some View {
        @Bindable var settings = settings
        @Bindable var app = app
        
        NavigationStack {
            TabView(selection: $settings.selectedTab) {
                NavigationView {
                    Monitor()
                }
                .tag(Tab.monitor)
                .tabItem {
                    Label("Monitor", systemImage: "gauge")
                }
                
#if !os(macOS) && !targetEnvironment(macCatalyst)
                NavigationView {
                    AppleHealthView()
                }
                .tag(Tab.healthKit)
                .tabItem {
                    Label("Apple Health", systemImage: "heart")
                }
#endif
                
                NavigationView {
                    SettingsView()
                }
                .tag(Tab.settings)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                
                NavigationView {
                    OnlineView()
                }
                .tag(Tab.online)
                .tabItem {
                    Label("Online", systemImage: "globe")
                }
                
                NavigationView {
                    Plan()
                }
                .tag(Tab.plan)
                .tabItem {
                    Label("Plan", systemImage: "map")
                }
                
                NavigationView {
                    Console()
                }
                .tag(Tab.console)
                .tabItem {
                    Label("Console", systemImage: "terminal")
                }
                
                NavigationView {
                    DebugView()
                }
                .tag(Tab.debug)
                .tabItem {
                    Label("Debug", systemImage: "hammer")
                }
            }
            .sheet($app.sheetNewRecord) {
                NewRecordView()
            }
            .alert("Notify when complete", isPresented: $app.alertActivation) {
                Button("Notify when the activation is complete") {
                    NotificationManager.shared.scheduleActivation(app.sensor.type)
                }
            }
            .alert("NFC not supported", isPresented: $app.alertNfc) {
                
            } message: {
                Text("This device doesn't allow scanning the Libre.")
            }
            .confirmationDialog("Pairing a Libre 2 with this device will break LibreLink and other apps' pairings and you will have to uninstall and reinstall them to get their alarms back again", isPresented: $app.dialogRePair, titleVisibility: .visible) {
                Button("RePair", role: .destructive) {
                    app.main.nfc.taskRequest = .enableStreaming
                }
            }
            .confirmationDialog("Unlocking the Libre 2 is not reversible and will make it unreadable by LibreLink and other apps", isPresented: $app.dialogUnlock, titleVisibility: .visible) {
                Button("Unlock", role: .destructive) {
                    app.main.nfc.taskRequest = .unlock
                }
            }
            .confirmationDialog("Resetting the sensor will clear its measurements memory and put it in an inactivated state", isPresented: $app.dialogReset, titleVisibility: .visible) {
                Button("Reset", role: .destructive) {
                    app.main.nfc.taskRequest = .reset
                }
            }
            .confirmationDialog("Prolonging the sensor will overwrite its maximum life to 0xFFFF minutes (≈ 45.5 days)", isPresented: $app.dialogProlong, titleVisibility: .visible) {
                Button("Prolong", role: .destructive) {
                    app.main.nfc.taskRequest = .prolong
                }
            }
            .confirmationDialog("Activating a fresh/ened sensor will put it in the usual warming-up state for 60 minutes", isPresented: $app.dialogActivate, titleVisibility: .visible) {
                Button("Activate", role: .destructive) {
                    app.main.nfc.taskRequest = .activate
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .glucosyPreview()
}

#Preview {
    HomeView()
        .glucosyPreview(.online)
}

#Preview {
    HomeView()
        .glucosyPreview(.data)
}

#Preview {
    HomeView()
        .glucosyPreview(.console)
}

#Preview {
    HomeView()
        .glucosyPreview(.settings)
}
