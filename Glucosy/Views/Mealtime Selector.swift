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
                Button {
                    value -= 5
                } label: {
                    Text("-5")
                        .padding()
                        .foregroundStyle(.white)
                        .background(.red.gradient, in: .rect(cornerRadius: 16))
                }
            }
            
            Button {
                value -= 1
            } label: {
                Text("-1")
                    .padding()
                    .foregroundStyle(.white)
                    .background(.red.gradient, in: .rect(cornerRadius: 16))
            }
            
            Text(Int(value))
                .padding()
                .monospaced()
            
            Button {
                value += 1
            } label: {
                Text("+1")
                    .padding()
                    .foregroundStyle(.white)
                    .background(.green.gradient, in: .rect(cornerRadius: 16))
            }
            
            if value > 10 {
                Button {
                    value += 5
                } label: {
                    Text("+5")
                        .padding()
                        .foregroundStyle(.white)
                        .background(.green.gradient, in: .rect(cornerRadius: 16))
                }
            }
        }
        .title(.semibold)
    }
}

#Preview {
    MealtimeSelector(.constant(16))
}
