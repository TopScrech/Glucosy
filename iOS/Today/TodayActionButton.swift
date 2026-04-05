import SwiftUI

struct TodayActionButton: View {
    let title: LocalizedStringKey
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var hapticTrigger = 0
    
    var body: some View {
        Button {
            hapticTrigger += 1
            action()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .title3()
                
                Text(title)
                    .title3(.semibold, design: .rounded)
                
                Spacer()
            }
            .padding(12)
            .background(.thinMaterial, in: .rect(cornerRadius: 14))
            .overlay(color.opacity(0.2), in: .rect(cornerRadius: 14))
        }
        .buttonStyle(.plain)
#if !os(visionOS)
        .hapticOn(hapticTrigger, as: .impact)
#endif
    }
}

#Preview {
    TodayActionButton(title: "Glucose", icon: "drop", color: .red) {}
        .padding()
        .darkSchemePreferred()
}
