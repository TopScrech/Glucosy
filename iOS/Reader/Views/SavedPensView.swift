import SwiftData
import SwiftUI

struct SavedPensView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedPen.createdAt) private var savedPens: [SavedPen]
    
    var body: some View {
        List {
            if savedPens.isEmpty {
                Section {
                    Text("No pens saved yet")
                        .secondary()
                }
            } else {
                ForEach(savedPens) {
                    SavedPenRow(pen: $0)
                }
                .onDelete(perform: deletePens)
            }
        }
        .navigationTitle("Saved Pens")
    }
    
    private func deletePens(at offsets: IndexSet) {
        for offset in offsets {
            modelContext.delete(savedPens[offset])
        }
        
        try? modelContext.save()
    }
}
