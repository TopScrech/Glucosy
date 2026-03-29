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
                Picker("Glucose", selection: $store.glucoseUnit) {
                    ForEach(GlucoseUnit.allCases) {
                        Text($0.title)
                            .tag($0)
                    }
                }
            }
            
            Section {
                Toggle(isOn: $store.debugMode) {
                    Label("Debug mode", systemImage: "hammer")
                }
            }
            
            if store.debugMode {
                Section("Debug Settings") {
                    NavigationLink("NovoPen Scan View") {
                        NovoPenReader()
                    }
                }
            }
            
            Section("NovoPen") {
                if savedPens.isEmpty {
                    Text("No saved pens yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(savedPens) { savedPen in
                        NavigationLink {
                            SavedPenEditorView(pen: savedPen)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(savedPen.title)
                                    
                                    Text(savedPen.insulinType.title)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                if !savedPen.serial.isEmpty {
                                    Text(savedPen.serial)
                                        .foregroundStyle(.secondary)
                                }
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
        }
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
