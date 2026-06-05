import SwiftUI
import SwiftData

struct SettingsNovopenSection: View {
    @EnvironmentObject private var store: ValueStore
    
#if canImport(CoreNFC)
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedPen.createdAt) private var savedPens: [SavedPen]
#endif
    
    var body: some View {
        Section("NovoPen") {
            if savedPens.isEmpty {
                Text("No saved pens yet")
                    .secondary()
            } else {
                ForEach(savedPens) {
                    SavedNovoPenCard($0)
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
    SettingsNovopenSection()
}
