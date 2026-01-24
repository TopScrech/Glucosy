import SwiftUI

struct LogWeightSheet: View {
    @State private var selectedValue = 64
    
    var body: some View {
        VStack {
            WheelPickerView(range: 15...150, selectedValue: $selectedValue) { currentValue in
                VStack {
                    Text(String(currentValue))
                        .rounded()
                        .monospacedDigit()
                        .fontSize(45)
                        .fontWeight(.black)
                        .numericTransition()
                        .animation(.snappy, value: currentValue)
                    
                    Text("KG")
                        .callout()
                        .foregroundStyle(.gray)
                }
                .padding(.top, 32)
            }
        }
        .navigationTitle("Wheel Picker")
        .padding(15)
    }
}

#Preview {
    NavigationStack {
        LogWeightSheet()
    }
    .darkSchemePreferred()
}
