import SwiftUI

struct Console: View {
    @Environment(AppState.self) private var app: AppState
    @Environment(Log.self)      private var log: Log
    @Environment(Settings.self) private var settings: Settings
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var showingRePairConfirmationDialog = false
    @State private var showingUnlockConfirmationDialog = false
    @State private var showingResetConfirmationDialog = false
    @State private var showingProlongConfirmationDialog = false
    @State private var showingActivateConfirmationDialog = false
    
    @State private var showingFilterField = false
    @State private var filterText = ""
    
    private func repair() {
        ((app.device as? Abbott)?.sensor as? Libre3)?.pair()
        
        guard app.main.nfc.isAvailable else {
            app.showingNfcAlert = true
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
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                //                ShellView()
                
                if showingFilterField {
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .padding(.leading)
                                .foregroundColor(Color(.lightGray))
                            
                            TextField("Filter", text: $filterText)
                                .textInputAutocapitalization(.never)
                                .foregroundColor(.accentColor)
                            
                            if filterText.count > 0 {
                                Button {
                                    filterText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .padding(.trailing)
                                }
                            }
                        }
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        
                        HStack {
                            let labels = Array(log.labels)
                            
                            ForEach(labels, id: \.self) { label in
                                Button(label) {
                                    filterText = label
                                }
                                .footnote()
                                .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.vertical, 6)
                }
                
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: true) {
                        LazyVStack(alignment: .leading, spacing: 20) {
                            if filterText.isEmpty {
                                ForEach(log.entries) { entry in
                                    Text(entry.message)
                                        .textSelection(.enabled)
                                }
                            } else {
                                let pattern = filterText.lowercased()
                                let entries = log.entries.filter {
                                    $0.message.lowercased().contains(pattern)
                                }
                                
                                ForEach(entries) { entry in
                                    Text(entry.message)
                                        .textSelection(.enabled)
                                }
                            }
                        }
                        .padding(4)
                    }
                    .footnote(design: .monospaced)
                    .foregroundColor(colorScheme == .dark ? Color(.lightGray) : Color(.darkGray))
                    .onChange(of: log.entries.count) {
                        if !settings.reversedLog {
                            withAnimation {
                                proxy.scrollTo(log.entries.last!.id, anchor: .bottom)
                            }
                        } else {
                            withAnimation {
                                proxy.scrollTo(log.entries[0].id, anchor: .top)
                            }
                        }
                    }
                    .onChange(of: log.entries[0].id) {
                        if !settings.reversedLog {
                            withAnimation {
                                proxy.scrollTo(log.entries.last!.id, anchor: .bottom)
                            }
                        } else {
                            withAnimation {
                                proxy.scrollTo(log.entries[0].id, anchor: .top)
                            }
                        }
                    }
                }
            }
#if targetEnvironment(macCatalyst)
            .padding(.horizontal, 15)
#endif
            
            ConsoleSidebar()
#if targetEnvironment(macCatalyst)
                .padding(.trailing, 15)
#endif
        }
        .navigationTitle("Console")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    settings.caffeinated.toggle()
                    UIApplication.shared.isIdleTimerDisabled = settings.caffeinated
                } label: {
                    Image(systemName: settings.caffeinated ? "cup.and.saucer.fill" : "cup.and.saucer" )
                        .tint(.latte)
                }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    withAnimation {
                        showingFilterField.toggle()
                    }
                } label: {
                    VStack(spacing: 0) {
                        Image(systemName: filterText.isEmpty ? "line.horizontal.3.decrease.circle" : "line.horizontal.3.decrease.circle.fill")
                        
                        Text("Filter")
                            .footnote()
                    }
                }
                
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
                            app.showingNfcAlert = true
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
                                app.showingNfcAlert = true
                            }
                        } label: {
                            Label("Unlock", systemImage: "lock.open")
                        }
                        
                        Button {
                            if app.main.nfc.isAvailable {
                                settings.logging = true
                                showingResetConfirmationDialog = true
                            } else {
                                app.showingNfcAlert = true
                            }
                        } label: {
                            Label("Reset", systemImage: "00.circle")
                        }
                        
                        Button {
                            if app.main.nfc.isAvailable {
                                settings.logging = true
                                showingProlongConfirmationDialog = true
                            } else {
                                app.showingNfcAlert = true
                            }
                        } label: {
                            Label("Prolong", systemImage: "infinity.circle")
                        }
                        
                        Button {
                            if app.main.nfc.isAvailable {
                                settings.logging = true
                                showingActivateConfirmationDialog = true
                            } else {
                                app.showingNfcAlert = true
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
                            app.showingNfcAlert = true
                        }
                    } label: {
                        Label("Dump Memory", systemImage: "cpu")
                    }
                } label: {
                    VStack(spacing: 0) {
                        Image(systemName: "wrench.and.screwdriver")
                        
                        Text("Tools")
                            .footnote()
                    }
                }
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
