import SwiftUI

struct LogDietaryEnergyView: View {
    @Environment(HealthKit.self) private var healthKit
    @Environment(\.dismiss) private var dismiss
    @State private var form = LogDietaryEnergyVM()
    @FocusState private var isAmountFocused: Bool
    
    init(initialAmount: Double? = nil) {
        _form = State(initialValue: LogDietaryEnergyVM(initialAmount: initialAmount))
    }

    var body: some View {
        Form {
            Section {
                DatePicker("Date", selection: $form.date, displayedComponents: .date)
                DatePicker("Time", selection: $form.date, displayedComponents: .hourAndMinute)
                
                HStack {
                    Text("kcal")
                        .foregroundStyle(.secondary)
                    
                    TextField("Energy", text: $form.amount)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .focused($isAmountFocused)
                }
            }
            .disabled(form.isSaving)
            
            if let errorMessage = form.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Dietary Energy")
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled(form.isSaving)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark") {
                    dismiss()
                }
                .disabled(form.isSaving)
                .tint(.red)
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", systemImage: "checkmark") {
                    Task {
                        if await form.save(action: healthKit.writeDietaryEnergy) {
                            dismiss()
                        }
                    }
                }
                .disabled(!form.canSave)
            }
        }
        .overlay {
            if form.isSaving {
                ProgressView("Saving")
            }
        }
        .task {
            await Task.yield()
            isAmountFocused = true
        }
    }
}
