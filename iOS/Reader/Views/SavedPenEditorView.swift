import SwiftData
import SwiftUI

struct SavedPenEditorView: View {
    @Bindable var pen: SavedPen
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var showsDeleteConfirmation = false
    
    var body: some View {
        List {
            Section {
                TextField("Pen Name", text: $pen.customName)
            } header: {
                Text("Name")
            }
            
            Section {
                LabeledContent("Model") {
                    Text(pen.model.isEmpty ? String(localized: "Unavailable") : pen.model)
                }
                
                LabeledContent("Serial") {
                    Text(pen.serial.isEmpty ? String(localized: "Unavailable") : pen.serial)
                }
            } header: {
                Text("Details")
            }
            
            Section {
                Picker("Type", selection: $pen.insulinType) {
                    ForEach(InsulinType.allCases) {
                        Text($0.title)
                            .tag($0)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Text("Insulin Type")
            }
        }
        .navigationTitle(pen.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Delete", systemImage: "trash", role: .destructive) {
                    showsDeleteConfirmation = true
                }
                .tint(.red)
            }
        }
        .alert("Delete Pen", isPresented: $showsDeleteConfirmation) {
            Button("Delete", systemImage: "trash", role: .destructive, action: deletePen)
            Button("Cancel", role: .cancel) {}
        }
        .onChange(of: pen.customName) {
            try? modelContext.save()
        }
        .onChange(of: pen.insulinType) {
            try? modelContext.save()
        }
    }
    
    private func deletePen() {
        modelContext.delete(pen)
        try? modelContext.save()
        dismiss()
    }
}
