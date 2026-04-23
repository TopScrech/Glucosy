import SwiftUI

@available(iOS 26, *)
struct FoundationModelChatMessageBubble: View {
    let message: FoundationModelChatMessage
    let onLogCarbs: (ChatCarbDraft) -> Void
    
    var body: some View {
        HStack {
            if message.role == .assistant {
                VStack(alignment: .leading) {
                    Text(message.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if message.isFullyRevealed, let carbGramsToLog = message.response?.logCarbsAction?.carbGrams, carbGramsToLog > 0 {
                        Button(buttonTitle(for: carbGramsToLog), systemImage: "fork.knife") {
                            onLogCarbs(ChatCarbDraft(carbsAmount: carbGramsToLog))
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                
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
