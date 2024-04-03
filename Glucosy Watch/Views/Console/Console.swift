import SwiftUI

struct Console: View {
    @Environment(AppState.self) private var app: AppState
    @Environment(Settings.self) private var settings: Settings
    @Environment(Log.self)      private var log: Log
    
    @State private var showFilterField = false
    @State private var filterText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                if showFilterField {
                    ScrollView {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color(.lightGray))
                            
                            TextField("Filter", text: $filterText)
                                .foregroundColor(.blue)
                                .textInputAutocapitalization(.never)
                            
                            if filterText.count > 0 {
                                Button {
                                    filterText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .frame(maxWidth: 24)
                                        .padding(0)
                                }
                                .buttonStyle(.plain)
                                .foregroundColor(.blue)
                            }
                        }
                        
                        // TODO: picker to filter labels
                        let labels = Array(log.labels)
                        
                        ForEach(labels, id: \.self) { label in
                            Button(label) {
                                filterText = label
                            }
                            .caption()
                            .foregroundColor(.blue)
                        }
                    }
                }
                
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: true) {
                        LazyVStack(alignment: .leading, spacing: 10) {
                            if filterText.isEmpty {
                                ForEach(log.entries) { entry in
                                    Text(entry.message)
                                }
                            } else {
                                let pattern = filterText.lowercased()
                                
                                let entries = log.entries.filter {
                                    $0.message.lowercased().contains(pattern)
                                }
                                
                                ForEach(entries) { entry in
                                    Text(entry.message)
                                }
                            }
                        }
                    }
                    // .footnote(design: .monospaced)
                    // .foregroundColor(Color(.lightGray))
                    .footnote()
                    .foregroundColor(Color(.lightGray))
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
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        withAnimation {
                            showFilterField.toggle()
                        }
                    } label: {
                        Image(systemName: filterText.isEmpty ? "line.horizontal.3.decrease.circle" : "line.horizontal.3.decrease.circle.fill")
                            .title3()
                        
                        Text("Filter")
                    }
                }
            }
            .buttonStyle(.plain)
            .foregroundColor(.blue)
            
            ConsoleTools()
        }
        .navigationTitle("Console")
        
        // FIXME: Filter toolbar item disappearing
        // .padding(.top, -4)
        .edgesIgnoringSafeArea(.bottom)
        .tint(.blue)
    }
}

#Preview {
    Console()
        .glucosyPreview(.console)
}
