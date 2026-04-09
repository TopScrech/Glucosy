import ScrechKit

struct TodayActionButton: View {
    private let title: LocalizedStringKey
    private let icon: String
    private let color: Color
    private let action: () -> Void
    
    init(_ title: LocalizedStringKey, icon: String, color: Color, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }
    
    @State private var hapticTrigger = false
    
    var body: some View {
        Button {
            hapticTrigger.toggle()
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
    TodayActionButton("Glucose", icon: "drop", color: .red) {}
        .padding()
        .darkSchemePreferred()
}
