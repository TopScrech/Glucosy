import SwiftUI

@available(iOS 26, *)
struct FoundationModelChatActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(title, systemImage: systemImage, action: action)
            .buttonStyle(.borderedProminent)
            .transition(
                .offset(x: -12, y: -12)
                    .combined(with: .scale(scale: 0.50, anchor: .topLeading))
                    .combined(with: .opacity)
            )
    }
}
