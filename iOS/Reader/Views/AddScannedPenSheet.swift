import SwiftData
import SwiftUI

struct AddScannedPenSheet: View {
    let reading: PenReading
    let onSaved: (InsulinType) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var errorMessage: String?
    @State private var insulinType: InsulinType = .bolus
    @State private var showsError = false
    
    var body: some View {
        List {
            Section("Scanned Pen") {
                LabeledContent("Model") {
                    Text(reading.modelDisplayValue)
                }
                
                LabeledContent("Serial") {
                    Text(reading.serialDisplayValue)
                }
            }
            
            Section {
                Picker("Type", selection: $insulinType) {
                    ForEach(InsulinType.allCases) {
                        Text($0.title)
                            .tag($0)
                    }
                }
            } footer: {
                Text("This saved pen type will be reused for future NovoPen scans")
            }
        }
        .navigationTitle("Add Pen")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    savePen()
                }
                .bold()
            }
        }
        .alert("Could Not Save Pen", isPresented: $showsError) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private func savePen() {
        do {
            let savedPen = SavedPen(
                model: reading.model,
                serial: reading.serial,
                insulinType: insulinType
            )
            
            modelContext.insert(savedPen)
            try modelContext.save()
            onSaved(insulinType)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showsError = true
        }
    }
}
