import ScrechKit

struct StandartToolbar: ViewModifier {
    @Environment(AppState.self) private var app: AppState
    @Environment(Settings.self) private var settings: Settings
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    SFButton("note.text") {
                        app.sheetNewRecord = true
                    }
                    .tint(.yellow)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            app.main.nfc.startSession()
                        } label: {
                            Label("Scan", systemImage: "sensor.tag.radiowaves.forward.fill")
                        }
                        
                        Divider()
                        
                        Menu {
                            Button {
                                if app.main.nfc.isAvailable {
                                    settings.logging = true
                                    app.dialogActivate = true
                                } else {
                                    app.alertNfc = true
                                }
                            } label: {
                                Label("Activate", systemImage: "bolt")
                            }
                            
                            Button {
                                if app.main.nfc.isAvailable {
                                    settings.logging = true
                                    app.dialogUnlock = true
                                } else {
                                    app.alertNfc = true
                                }
                            } label: {
                                Label("Unlock", systemImage: "lock.open")
                            }
                            
                            Button {
                                if app.main.nfc.isAvailable {
                                    settings.logging = true
                                    app.dialogReset = true
                                } else {
                                    app.alertNfc = true
                                }
                            } label: {
                                Label("Reset", systemImage: "gearshape.arrow.triangle.2.circlepath")
                            }
                            
                            Button {
                                if app.main.nfc.isAvailable {
                                    settings.logging = true
                                    app.dialogProlong = true
                                } else {
                                    app.alertNfc = true
                                }
                            } label: {
                                Label("Prolong", systemImage: "infinity")
                            }
                        } label: {
                            Label("Hacks", systemImage: "wand.and.stars")
                        }
                        
                    } label: {
                        Image(systemName: "sensor.tag.radiowaves.forward.fill")
                            .tint(.white)
                            .symbolEffect(.variableColor.reversing)
                        
                    } primaryAction: {
                        app.main.nfc.startSession()
                    }
                }
            }
    }
}

extension View {
    func standardToolbar() -> some View {
        self
            .modifier(StandartToolbar())
    }
}
