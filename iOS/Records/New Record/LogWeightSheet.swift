import ScrechKit

struct LogWeightSheet: View {
    @Environment(HealthKit.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    @State private var date = Date()
    @State private var weightString = ""
    @FocusState private var isWeightFieldFocused: Bool
    
    private var weight: Double? {
        Double(weightString.replacing(",", with: "."))
    }
    
    var body: some View {
        List {
            Section {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .secondary()

                DatePicker("Time", selection: $date, displayedComponents: .hourAndMinute)
                    .secondary()

                HStack {
                    Text("Weight")
                        .secondary()
                    
                    Spacer()

                    TextField("", text: $weightString)
                        .focused($isWeightFieldFocused)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)

                    Text("KG")
                }
            }
        }
        .navigationTitle("Weight")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await Task.yield()
            isWeightFieldFocused = true
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(role: .destructive) {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
                .tint(.red)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                SFButton("checkmark", action: saveRecord)
                    .disabled(weight == nil)
            }
        }
    }
    
    private func saveRecord() {
        guard let weight else { return }
        
        vm.writeWeight(value: weight, date: date)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        LogWeightSheet()
    }
    .darkSchemePreferred()
    .environment(HealthKit())
}
