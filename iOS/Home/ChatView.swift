import SwiftUI

struct ChatView: View {
    var body: some View {
#if canImport(FoundationModels)
        Group {
            if #available(iOS 26, visionOS 26, *) {
                FoundationModelChatView()
            } else {
                ContentUnavailableView(
                    "Assistant Unavailable",
                    systemImage: "apple.intelligence",
                    description: Text("This chat requires a newer iOS version")
                )
                .symbolRenderingMode(.multicolor)
            }
        }
#else
        ContentUnavailableView(
            "Assistant Unavailable",
            systemImage: "apple.intelligence",
            description: Text("Apple Intelligence is not available in this build")
        )
        .symbolRenderingMode(.multicolor)
#endif
    }
}

#Preview {
    NavigationStack {
        ChatView()
    }
    .environmentObject(ValueStore())
}
