import SwiftUI

// TODO: Numeric Type

struct MealtimeSelector: View {
    @Binding private var value: Double
    
    init(_ value: Binding<Double>) {
        _value = value
    }
    
    var body: some View {
        HStack(spacing: 50) {
            Button {
                value -= 1
            } label: {
                Text("-1")
                    .padding()
                    .foregroundStyle(.white)
                    .background(.red.gradient, in: .rect(cornerRadius: 16))
            }
            
            Text(Int(value))
                .monospaced()
//                .animation(.default, value: amountInsulin)
            //                    .modifier(NumericContentTransitionModifier(newValue: amountInsulin, oldValue: vm.previousValue))
            
            Button {
                value += 1
            } label: {
                Text("+1")
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
