import SwiftUI
import SwiftData

struct SavedPenEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Bindable private var pen: SavedPen
    
    init(_ pen: SavedPen) {
        self.pen = pen
    }
    
    @State private var showsDeleteConfirmation = false
    
    var body: some View {
        List {
            Section("Name") {
                TextField("Pen Name", text: $pen.customName)
            }
            
            Section("Details") {
                LabeledContent("Model") {
                    Text(pen.model.isEmpty ? String(localized: "Unavailable") : pen.model)
                }
                
                LabeledContent("Serial") {
                    Text(pen.serial.isEmpty ? String(localized: "Unavailable") : pen.serial)
                }
            }
            
            Section("Insulin Type") {
                Picker("Type", selection: $pen.insulinType) {
                    ForEach(InsulinType.allCases) {
                        Text($0.title)
                            .tag($0)
                    }
                }
                .pickerStyle(.segmented)
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
