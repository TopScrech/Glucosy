import SwiftUI

struct ConsoleTools: View {
    @Environment(AppState.self) private var app: AppState
    @Environment(Settings.self) private var settings: Settings
    
    @State private var showingRePairConfirmationDialog = false
    @State private var showingUnlockConfirmationDialog = false
    @State private var showingResetConfirmationDialog = false
    @State private var showingProlongConfirmationDialog = false
    @State private var showingActivateConfirmationDialog = false
    
    private func repair() {
        ((app.device as? Abbott)?.sensor as? Libre3)?.pair()
        
        guard app.main.nfc.isAvailable else {
            app.alertNfc = true
            return
        }
        
        settings.logging = true
        settings.selectedTab = .console
        
        if app.sensor as? Libre3 == nil {
            showingRePairConfirmationDialog = true
        } else {
            app.main.nfc.taskRequest = .enableStreaming
        }
    }
    
    var body: some View {
        Menu {
            Button {
                repair()
            } label: {
                Label("RePair Streaming", systemImage: "sensor.tag.radiowaves.forward.fill")
            }
            
            Button {
                if app.main.nfc.isAvailable {
                    settings.logging = true
                    app.main.nfc.taskRequest = .readFRAM
                } else {
                    app.alertNfc = true
                }
            } label: {
                Label("Read FRAM", systemImage: "memorychip")
            }
            
            Menu {
                Button {
                    if app.main.nfc.isAvailable {
                        settings.logging = true
                        showingUnlockConfirmationDialog = true
                    } else {
                        app.alertNfc = true
                    }
                } label: {
                    Label("Unlock", systemImage: "lock.open")
                }
                
                Button {
                    if app.main.nfc.isAvailable {
                        settings.logging = true
                        showingResetConfirmationDialog = true
                    } else {
                        app.alertNfc = true
                    }
                } label: {
                    Label("Reset", systemImage: "00.circle")
                }
                
                Button {
                    if app.main.nfc.isAvailable {
                        settings.logging = true
                        showingProlongConfirmationDialog = true
                    } else {
                        app.alertNfc = true
                    }
                } label: {
                    Label("Prolong", systemImage: "infinity.circle")
                }
                
                Button {
                    if app.main.nfc.isAvailable {
                        settings.logging = true
                        showingActivateConfirmationDialog = true
                    } else {
                        app.alertNfc = true
                    }
                } label: {
                    Label("Activate", systemImage: "bolt.circle")
                }
            } label: {
                Label("Hacks", systemImage: "wand.and.stars")
            }
            
            Button {
                if app.main.nfc.isAvailable {
                    settings.logging = true
                    app.main.nfc.taskRequest = .dump
                } else {
                    app.alertNfc = true
                }
            } label: {
                Label("Dump Memory", systemImage: "cpu")
            }
        } label: {
            VStack {
                Image(systemName: "wrench.and.screwdriver")
                    .title3()
                
                Text("Tools")
                    .foregroundStyle(.gray)
            }
        }
        .confirmationDialog("Pairing a Libre 2 with this device will break LibreLink and other apps' pairings and you will have to uninstall and reinstall them to get their alarms back again.", isPresented: $showingRePairConfirmationDialog, titleVisibility: .visible) {
            Button("RePair", role: .destructive) {
                app.main.nfc.taskRequest = .enableStreaming
            }
        }
        .confirmationDialog("Unlocking the Libre 2 is not reversible and will make it unreadable by LibreLink and other apps.", isPresented: $showingUnlockConfirmationDialog, titleVisibility: .visible) {
            Button("Unlock", role: .destructive) {
                app.main.nfc.taskRequest = .unlock
            }
        }
        .confirmationDialog("Resetting the sensor will clear its measurements memory and put it in an inactivated state.", isPresented: $showingResetConfirmationDialog, titleVisibility: .visible) {
            Button("Reset", role: .destructive) {
                app.main.nfc.taskRequest = .reset
            }
        }
        .confirmationDialog("Prolonging the sensor will overwrite its maximum life to 0xFFFF minutes (≈ 45.5 days)", isPresented: $showingProlongConfirmationDialog, titleVisibility: .visible) {
            Button("Prolong", role: .destructive) {
                app.main.nfc.taskRequest = .prolong
            }
        }
        .confirmationDialog("Activating a fresh/ened sensor will put it in the usual warming-up state for 60 minutes.", isPresented: $showingActivateConfirmationDialog, titleVisibility: .visible) {
            Button("Activate", role: .destructive) {
                app.main.nfc.taskRequest = .activate
            }
        }
    }
}

#Preview {
    HomeView()
        .glucosyPreview(.console)
}
