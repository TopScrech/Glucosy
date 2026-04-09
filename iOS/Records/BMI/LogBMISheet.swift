import ScrechKit

struct LogBMISheet: View {
    @Environment(HealthKit.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    @State private var date = Date()
    @State private var bmiString = ""
    @FocusState private var isBMIFieldFocused: Bool
    
    private var bmi: Double? {
        Double(bmiString.replacing(",", with: "."))
    }
    
    var body: some View {
        List {
            Section {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .secondary()
                
                DatePicker("Time", selection: $date, displayedComponents: .hourAndMinute)
                    .secondary()
                
                HStack {
                    Text("BMI")
                        .secondary()
                    
                    Spacer()
                    
                    TextField("", text: $bmiString)
                        .focused($isBMIFieldFocused)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                }
            }
        }
        .navigationTitle("BMI")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await Task.yield()
            isBMIFieldFocused = true
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add") {
                    guard let bmi else {
                        return
                    }
                    
                    vm.writeBMI(value: bmi, date: date)
                    dismiss()
                }
                .bold()
                .disabled(bmi == nil)
            }
        }
    }
}

#Preview {
    NavigationStack {
        LogBMISheet()
    }
    .darkSchemePreferred()
    .environment(HealthKit())
}
