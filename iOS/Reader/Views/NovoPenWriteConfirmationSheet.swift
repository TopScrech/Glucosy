import ScrechKit

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
                        .secondary()
                }
            } else {
                Section {
                    LabeledContent("Pen") {
                        Text(vm.penTitle)
                    }
                    
                    LabeledContent("Type") {
                        Text(vm.insulinType.title)
                    }
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
                    HStack {
                        Text("New Doses")
                        Spacer()
                        Text("\(vm.selectedDoseCount) dose(s) selected")
                    }
                }
            }
        }
        .navigationTitle("New doses")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                SFButton("xmark") {
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
