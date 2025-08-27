import SwiftUI

struct LogWeightSheet: View {
    @State private var selectedValue = 64
    
    var body: some View {
        VStack {
            if #available(iOS 18, *) {
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
            } else {
#warning("Todo")
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
}
