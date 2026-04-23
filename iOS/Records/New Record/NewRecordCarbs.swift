import ScrechKit

struct NewRecordCarbs: View {
    @Environment(HealthKit.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    @State private var date = Date()
    @State private var unitsString = ""
    @FocusState private var isUnitsFieldFocused: Bool
    
    init() {}
    
    init(initialAmount: Double) {
        _unitsString = State(initialValue: Self.initialUnitsString(for: initialAmount))
    }
    
    private var units: Double? {
        Double(unitsString.replacing(",", with: "."))
    }
    
    var body: some View {
        List {
            Section {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .secondary()
                
                DatePicker("Time", selection: $date, displayedComponents: .hourAndMinute)
                    .secondary()
                
                HStack {
                    Text("g")
                        .secondary()
                    
                    Spacer()
                    
                    TextField("", text: $unitsString)
                        .focused($isUnitsFieldFocused)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                }
            }
        }
        .navigationTitle("Carbohydrates")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await Task.yield()
            isUnitsFieldFocused = true
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
                    .disabled(units == nil)
            }
        }
    }
    
    private func saveRecord() {
        guard let units else { return }
        
        vm.writeCarbs(value: units, date: date)
        dismiss()
    }
    
    private static func initialUnitsString(for amount: Double) -> String {
        return amount.formatted(.number.precision(.fractionLength(0 ... 1)))
    }
}

#Preview {
    NewRecordCarbs()
        .darkSchemePreferred()
        .environment(HealthKit())
}
