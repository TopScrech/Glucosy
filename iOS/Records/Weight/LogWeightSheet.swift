import ScrechKit

struct LogWeightSheet: View {
    @Environment(HealthKit.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedValue = 64
    
    var body: some View {
        VStack {
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
        .navigationTitle("Weight")
        .navigationBarTitleDisplayMode(.inline)
        .padding(15)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add") {
                    vm.writeWeight(value: Double(selectedValue))
                    dismiss()
                }
                .bold()
            }
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
