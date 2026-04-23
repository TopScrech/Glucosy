import SwiftUI

@available(iOS 26, *)
struct FoundationModelChatMessageBubble: View {
    let message: ChatMessage
    let onLogCarbs: (ChatCarbDraft) -> Void
    
    var body: some View {
        let carbGramsToLog = message.response?.logCarbsAction?.carbGrams
        let showsLogCarbsButton = message.isFullyRevealed && (carbGramsToLog ?? 0) > 0
        
        HStack {
            if message.role == .assistant {
                VStack(alignment: .leading) {
                    Text(message.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if let carbGramsToLog, showsLogCarbsButton {
                        ChatActionButton(
                            title: buttonTitle(for: carbGramsToLog),
                            systemImage: "fork.knife"
                        ) {
                            onLogCarbs(ChatCarbDraft(carbsAmount: carbGramsToLog))
                        }
                    }
                }
                .animation(.snappy(duration: 0.35, extraBounce: 0.08), value: showsLogCarbsButton)
                
                Spacer()
            } else {
                Text(message.text)
                    .padding()
                    .background(.tint.opacity(0.15), in: .rect(cornerRadius: 20))
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
    
    private func buttonTitle(for carbGramsToLog: Double) -> String {
        "\(carbGramsToLog.formatted(.number.precision(.fractionLength(0 ... 1))))g carbs"
    }
}
