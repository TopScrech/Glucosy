import ScrechKit

struct NewRecordGlucose: View {
    @Environment(HealthKit.self) private var vm
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: ValueStore
    
    @State private var date = Date()
    @State private var unitsString = ""
    @State private var mealTime: MealType = .unspecified
    @FocusState private var isUnitsFieldFocused: Bool
    
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
                    Text("Blood Glucose")
                        .secondary()
                    
                    Spacer()
                    
                    TextField("", text: $unitsString)
                        .focused($isUnitsFieldFocused)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                    
                    Text(store.glucoseUnit.title)
                }
                
                Picker("Meal Time", selection: $mealTime) {
                    ForEach(MealType.allCases) {
                        Text($0.title)
                            .tag($0)
                    }
                }
                .secondary()
            }
        }
        .navigationTitle("Blood Glucose")
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
        
        vm.writeGlucose(
            value: store.glucoseUnit.milligramsPerDeciliter(fromDisplayValue: units),
            date: date
        )
        
        dismiss()
    }
}

#Preview {
    NewRecordGlucose()
        .darkSchemePreferred()
        .environment(HealthKit())
        .environmentObject(ValueStore())
}
