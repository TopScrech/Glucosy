import ScrechKit
import ChitChat

@available(iOS 26, *)
struct ChatMessageBubble: View {
    let message: ChatMessage
    let onLogCarbs: (ChatCarbDraft) -> Void
    let onStartNewChat: () -> Void
    
    var body: some View {
        let carbGramsToLog = message.response?.logCarbsAction?.carbGrams
        let showsLogCarbsButton = message.isFullyRevealed && (carbGramsToLog ?? 0) > 0
        
        HStack {
            if message.role == .assistant {
                VStack(alignment: .leading) {
                    if let name = message.name {
                        Text(name)
                            .secondary()
                    }
                    
                    Text(message.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if let carbGramsToLog, showsLogCarbsButton {
                        ChatActionButton(buttonTitle(for: carbGramsToLog), systemImage: "fork.knife") {
                            onLogCarbs(ChatCarbDraft(carbsAmount: carbGramsToLog))
                        }
                    }
                    
                    if message.showsStartNewChatAction {
                        ChatActionButton("New chat", systemImage: "plus.message", action: onStartNewChat)
                    }
                }
                .padding()
                .background(.gray.opacity(0.15), in: .rect(cornerRadius: 20))
                .padding(.vertical, 8)
                .animation(.snappy(duration: 0.35, extraBounce: 0.08), value: showsLogCarbsButton)
                .animation(.snappy(duration: 0.35, extraBounce: 0.08), value: message.showsStartNewChatAction)
                
                Spacer()
            } else {
                VStack(alignment: .trailing) {
                    if !message.attachments.isEmpty {
                        ChatImageStrip(attachments: message.attachments)
                    }
                    if !message.text.isEmpty {
                        Text(message.text)
                    }
                }
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
