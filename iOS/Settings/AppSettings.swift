import SwiftData
import SwiftUI
import Appearance

struct AppSettings: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var store: ValueStore
    @Query(sort: \SavedPen.createdAt) private var savedPens: [SavedPen]
    
    var body: some View {
        List {
#if !os(visionOS)
            AppearancePicker($store.appearance)
#endif
            
            Section("Units") {
                HStack {
                    Text("Glucose")
                    
                    Spacer(minLength: 80)
                    
                    Picker("Glucose", selection: $store.glucoseUnit) {
                        ForEach(GlucoseUnit.allCases) {
                            Text($0.title)
                                .tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            
            Section {
                Toggle(isOn: $store.debugMode) {
                    Label("Debug mode", systemImage: "hammer")
                }
            }
            
            Section("NovoPen") {
                if savedPens.isEmpty {
                    Text("No saved pens yet")
                        .secondary()
                } else {
                    ForEach(savedPens) { savedPen in
                        NavigationLink {
                            SavedPenEditorView(pen: savedPen)
                        } label: {
                            HStack {
                                Text(savedPen.title)
                                
                                Spacer()
                                
                                Text(savedPen.insulinType.title)
                                    .secondary()
                            }
                        }
                    }
                    .onDelete(perform: deletePens)
                }
                
                Picker("Hide Airshots", selection: $store.airshotFilter) {
                    ForEach(AirshotFilter.allCases) {
                        Text($0.title)
                            .tag($0)
                    }
                }
            }
            
            if store.debugMode {
                Section("Debug Settings") {
                    Toggle(String("Hide Status Bar"), isOn: $store.debugHideStatusBar)
                    
                    NavigationLink("NovoPen Scan View") {
                        NovoPenReader()
                    }
                }
            }
        }
        .navigationTitle("Settings")
    }
    
    private func deletePens(at offsets: IndexSet) {
        for offset in offsets {
            modelContext.delete(savedPens[offset])
        }
        
        try? modelContext.save()
    }
}

#Preview {
    AppSettings()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
        .modelContainer(for: [SavedPen.self], inMemory: true)
}
