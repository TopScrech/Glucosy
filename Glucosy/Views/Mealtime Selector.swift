import SwiftUI

// TODO: Numeric Type

struct MealtimeSelector: View {
    @Binding private var value: Double
    
    init(_ value: Binding<Double>) {
        _value = value
    }
    
    var body: some View {
        HStack(spacing: 10) {
            if value > 10 {
                Button("-5") {
                    value -= 5
                }
                .padding()
                .foregroundStyle(.white)
                .background(.red.gradient, in: .rect(cornerRadius: 16))
            }
            
            Button("-1") {
                value -= 1
            }
            .padding()
            .foregroundStyle(.white)
            .background(.red.gradient, in: .rect(cornerRadius: 16))
            
            Text(Int(value))
                .padding()
                .monospaced()
            
            Button("+1") {
                value += 1
            }
            .padding()
            .foregroundStyle(.white)
            .background(.green.gradient, in: .rect(cornerRadius: 16))
            
            if value > 10 {
                Button("+5") {
                    value += 5
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
