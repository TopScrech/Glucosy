import ScrechKit

struct NovoPenWriteConfirmationSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var vm: NovoPenWriteConfirmationVM
    let healthKit: HealthKit
    
    var body: some View {
        List {
            if vm.savedDoses.isEmpty {
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
                
                Section("New Doses") {
                    ForEach(vm.savedDoses) { savedDose in
                        NovoPenSavedDoseRow(savedDose: savedDose)
                            .contextMenu {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    vm.remove(savedDose, using: healthKit)
                                }
                            }
                            .swipeActions {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    vm.remove(savedDose, using: healthKit)
                                }
                            }
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
            }
        }
    }
}
