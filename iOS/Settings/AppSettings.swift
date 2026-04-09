import SwiftData
import SwiftUI
import Appearance

struct AppSettings: View {
    @EnvironmentObject private var store: ValueStore
#if canImport(CoreNFC)
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedPen.createdAt) private var savedPens: [SavedPen]
#endif
    
    var body: some View {
        List {
#if !os(visionOS)
            AppearancePicker($store.appearance)
#endif
            GlucoseUnitPicker()
#if canImport(CoreNFC)
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
#endif
            Section {
                Toggle(isOn: $store.debugMode) {
                    Label("Debug mode", systemImage: "hammer")
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
    
#if canImport(CoreNFC)
    private func deletePens(at offsets: IndexSet) {
        for offset in offsets {
            modelContext.delete(savedPens[offset])
        }
        
        try? modelContext.save()
    }
#endif
}

#Preview {
    AppSettings()
        .darkSchemePreferred()
        .environmentObject(ValueStore())
#if canImport(CoreNFC)
        .modelContainer(for: [SavedPen.self], inMemory: true)
#endif
}
