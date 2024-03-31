import SwiftUI

struct ConsoleTools: View {
    @Environment(AppState.self) private var app: AppState
    @Environment(Settings.self) private var settings: Settings
    
    private func repair() {
        ((app.device as? Abbott)?.sensor as? Libre3)?.pair()
        
        guard app.main.nfc.isAvailable else {
            app.alertNfc = true
            return
        }
        
        settings.logging = true
        settings.selectedTab = .console
        
        if app.sensor as? Libre3 == nil {
            app.dialogRePair = true
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
    }
}

#Preview {
    HomeView()
        .glucosyPreview(.console)
}
