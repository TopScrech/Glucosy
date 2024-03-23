import SwiftUI

struct MealtimeSelector <Value> : View where Value: Numeric & Comparable, Value: Strideable, Value.Stride: FloatingPoint {
    @Binding private var value: Value
    private var step: Value
    private var largeStep: Value
    
    init(_ value: Binding<Value>, step: Value = 1, largeStep: Value = 5) {
        _value = value
        self.step = step
        self.largeStep = largeStep
    }
    
    var body: some View {
        HStack(spacing: 10) {
            if value > 10 {
                Button("-\(largeStep)") {
                    value -= largeStep
                }
                .padding()
                .foregroundStyle(.white)
                .background(.red.gradient, in: .rect(cornerRadius: 16))
            }
            
            Button("-\(step)") {
                value -= step
            }
            .padding()
            .foregroundStyle(.white)
            .background(.red.gradient, in: .rect(cornerRadius: 16))
            
            // Casting the generic Value to a String might require additional handling depending on the type
            Text("\(value)")
                .padding()
                .monospacedDigit()
            
            Button("+\(step)") {
                value += step
            }
            .padding()
            .foregroundStyle(.white)
            .background(.green.gradient, in: .rect(cornerRadius: 16))
            
            if value > 10 {
                Button("+\(largeStep)") {
                    value += largeStep
                }
                .padding()
                .foregroundStyle(.white)
                .background(.green.gradient, in: .rect(cornerRadius: 16))
            }
        }
        .title(.semibold)
    }
}

#Preview {
    MealtimeSelector(.constant(16))
}
