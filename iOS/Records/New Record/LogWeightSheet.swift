import ScrechKit

struct LogWeightSheet: View {
    @Environment(HealthKit.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    @State private var date = Date()
    @State private var selectedValue = 64
    @State private var enteredWeight = ""
    @FocusState private var isWeightFieldFocused: Bool
    
    private var fallbackWeight: Double? {
        Double(enteredWeight.replacing(",", with: "."))
    }
    
    var body: some View {
        Group {
            if #available(iOS 18, *) {
                List {
                    Section {
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                            .secondary()
                        
                        DatePicker("Time", selection: $date, displayedComponents: .hourAndMinute)
                            .secondary()
                    }
                    
                    Section {
                        WheelPickerView(range: 15...150, selectedValue: $selectedValue) { currentValue in
                            VStack {
                                Text(String(currentValue))
                                    .monospacedDigit()
                                    .largeTitle(.black, design: .rounded)
                                    .numericTransition()
                                    .animation(.snappy, value: currentValue)
                                
                                Text("KG")
                                    .callout()
                                    .foregroundStyle(.gray)
                            }
                            .padding(.top, 32)
                        }
                    }
                }
            } else {
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
                            
                            TextField("", text: $enteredWeight)
                                .focused($isWeightFieldFocused)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.decimalPad)
                            
                            Text("KG")
                        }
                    }
                }
                .task {
                    await Task.yield()
                    isWeightFieldFocused = true
                }
            }
        }
        .navigationTitle("Weight")
        .navigationBarTitleDisplayMode(.inline)
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
                    .disabled(saveDisabled)
            }
        }
    }
    
    private func saveRecord() {
        let value: Double
        
        if #available(iOS 18, *) {
            value = Double(selectedValue)
        } else {
            guard let fallbackWeight else { return }
            value = fallbackWeight
        }
        
        vm.writeWeight(value: value, date: date)
        dismiss()
    }
    
    private var saveDisabled: Bool {
        if #available(iOS 18, *) {
            false
        } else {
            fallbackWeight == nil
        }
    }
}

#Preview {
    NavigationStack {
        LogWeightSheet()
    }
    .darkSchemePreferred()
    .environment(HealthKit())
}
