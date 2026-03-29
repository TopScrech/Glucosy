import SwiftUI

struct NovoPenWriteConfirmationSheet: View {
    @Bindable var vm: NovoPenWriteConfirmationVM
    let healthKit: HealthKit
    
    @Environment(\.dismiss) private var dismiss
    @State private var errorMessage: String?
    @State private var showsError = false
    
    var body: some View {
        List {
            if vm.pendingDoses.isEmpty {
                Section {
                    Text("No new NovoPen doses were found")
                        .foregroundStyle(.secondary)
                }
            } else {
                Section {
                    LabeledContent("Pen") {
                        Text(vm.penTitle)
                    }
                    
                    LabeledContent("Type") {
                        Text(vm.insulinType.title)
                    }
                } header: {
                    Text("Saved Pen")
                } footer: {
                    Text("Selected doses will be written using the saved pen type")
                }
                
                Section {
                    ForEach(vm.pendingDoses) { pendingDose in
                        NovoPenPendingDoseRow(
                            pendingDose: pendingDose,
                            isSelected: vm.selectedDoseIDs.contains(pendingDose.id),
                            toggleSelection: {
                                vm.toggleSelection(for: pendingDose)
                            }
                        )
                    }
                } header: {
                    Text("New Doses")
                } footer: {
                    Text("\(vm.selectedDoseCount) dose(s) selected")
                }
            }
        }
        .navigationTitle("Confirm NovoPen Doses")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    vm.dismiss()
                    dismiss()
                }
                .disabled(vm.isWriting)
            }
            
            if !vm.pendingDoses.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", action: saveSelectedDoses)
                        .bold()
                        .disabled(vm.selectedDoseCount == 0 || vm.isWriting)
                }
            }
        }
        .alert("Could Not Write Doses", isPresented: $showsError) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private func saveSelectedDoses() {
        Task {
            do {
                try await vm.writeSelectedDoses(using: healthKit)
                vm.dismiss()
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showsError = true
            }
        }
    }
}
