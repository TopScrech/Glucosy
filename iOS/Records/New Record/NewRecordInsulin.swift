import ScrechKit

struct NewRecordInsulin: View {
    @Environment(HealthKit.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    @State private var date = Date()
    @State private var errorMessage: String?
    @State private var isAdding = false
    @State private var showsError = false
    @State private var unitsString = ""
    @State private var purpose: InsulinType = .bolus
    @FocusState private var isUnitsFieldFocused: Bool
    
    private var units: Double? {
        Double(unitsString.replacing(",", with: "."))
    }
    
    var body: some View {
        List {
            Section {
                DatePicker("Date", selection: $date)
                    .secondary()
                
                HStack {
                    Text("Units of Insulin")
                        .secondary()
                    
                    Spacer()
                    
                    TextField("", text: $unitsString)
                        .focused($isUnitsFieldFocused)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                }
                
                VStack(alignment: .leading) {
                    Text("Purpose")
                    
                    Picker("Purpose", selection: $purpose) {
                        ForEach(InsulinType.allCases) {
                            Text($0.title)
                                .tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .secondary()
            } footer: {
                Text("Basal insulin refers to the insulin used to regulate blood glucose between meals including during sleep. Bolus insulin refers to the insulin used to regulate blood glucose at meals and or to acutely address high blood glucose")
            }
        }
        .navigationTitle("Insulin Delivery")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await Task.yield()
            isUnitsFieldFocused = true
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add") {
                    guard let units else {
                        return
                    }
                    
                    Task {
                        do {
                            isAdding = true
                            try await vm.writeInsulin(value: units, type: purpose, date: date)
                            dismiss()
                        } catch {
                            errorMessage = error.localizedDescription
                            showsError = true
                            isAdding = false
                        }
                    }
                }
                .bold()
                .disabled(units == nil || isAdding)
            }
        }
        .alert("Could Not Add Insulin", isPresented: $showsError) {
            Button("OK") {
                errorMessage = nil
                isAdding = false
            }
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
    }
}

#Preview {
    NavigationStack {
        NewRecordInsulin()
    }
    .darkSchemePreferred()
    .environment(HealthKit())
}
