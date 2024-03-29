import SwiftUI

struct Console: View {
    @Environment(AppState.self) private var app: AppState
    @Environment(Log.self)      private var log: Log
    @Environment(Settings.self) private var settings: Settings
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        @Bindable var app = app
        
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                // ShellView()
                
                if app.showingConsoleFilterField {
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .padding(.leading)
                                .foregroundColor(Color(.lightGray))
                            
                            TextField("Filter", text: $app.filterText)
                                .textInputAutocapitalization(.never)
                                .foregroundColor(.accentColor)
                            
                            if app.filterText.count > 0 {
                                Button {
                                    app.filterText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .padding(.trailing)
                                }
                            }
                        }
                        .background(Color(.secondarySystemBackground))
                        .clipShape(.rect(cornerRadius: 10))
                        
                        HStack {
                            let labels = Array(log.labels)
                            
                            ForEach(labels, id: \.self) { label in
                                Button(label) {
                                    app.filterText = label
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
                            if app.filterText.isEmpty {
                                ForEach(log.entries) { entry in
                                    Text(entry.message)
                                        .textSelection(.enabled)
                                }
                                
                            } else {
                                let pattern = app.filterText.lowercased()
                                
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
                        withAnimation {
                            if !settings.reversedLog {
                                proxy.scrollTo(log.entries.last!.id, anchor: .bottom)
                            } else {
                                proxy.scrollTo(log.entries[0].id, anchor: .top)
                            }
                        }
                    }
                    .onChange(of: log.entries[0].id) {
                        withAnimation {
                            if !settings.reversedLog {
                                proxy.scrollTo(log.entries.last!.id, anchor: .bottom)
                            } else {
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
        }
        .standardToolbar()
    }
}

#Preview {
    HomeView()
        .glucosyPreview(.console)
}
