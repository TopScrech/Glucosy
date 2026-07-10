import ScrechKit

struct LogWeightSheet: View {
    private static let weightRange = 150...1_500
    private static let defaultWeight = 640

    @Environment(HealthKit.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    @State private var date = Date()
    @State private var selectedValue = Self.defaultWeight
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
                        WheelPickerView(range: Self.weightRange, selectedValue: $selectedValue) { currentValue in
                            VStack {
                                Text(Double(currentValue) / 10, format: .number.precision(.fractionLength(1)))
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
        .task {
            selectedValue = initialSelectedValue
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
                    .disabled(saveDisabled)
            }
        }
    }
    
    private func saveRecord() {
        let value: Double
        
        if #available(iOS 18, *) {
            value = Double(selectedValue) / 10
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

    private var initialSelectedValue: Int {
        guard let latestWeight = vm.weightRecords.first?.value else {
            return Self.defaultWeight
        }

        return min(
            max(Int((latestWeight * 10).rounded()), Self.weightRange.lowerBound),
            Self.weightRange.upperBound
        )
    }
}

#Preview {
    NavigationStack {
        LogWeightSheet()
    }
    .darkSchemePreferred()
    .environment(HealthKit())
}
