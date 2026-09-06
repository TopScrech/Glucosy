import ScrechKit
import ChitChat

@available(iOS 26, *)
struct ChatMessageBubble: View {
    let message: ChatMessage
    let onLogCarbs: (ChatCarbDraft) -> Void
    let onLogInsulin: (ChatInsulinDraft) -> Void
    let onLogDietaryEnergy: (ChatDietaryEnergyDraft) -> Void
    let onStartNewChat: () -> Void
    
    var body: some View {
        let carbGramsToLog = message.response?.logCarbsAction?.carbGrams
        let showsLogCarbsButton = message.isFullyRevealed && (carbGramsToLog?.isFinite ?? false) && (carbGramsToLog ?? 0) > 0
        let insulinAction = message.response?.logInsulinAction
        let showsLogInsulinButton = message.isFullyRevealed && (insulinAction?.units.isFinite ?? false) && (insulinAction?.units ?? 0) > 0
        
        let dietaryEnergyAction = message.response?.logDietaryEnergyAction
        let showsLogDietaryEnergyButton = message.isFullyRevealed && (dietaryEnergyAction?.kilocalories.isFinite ?? false) && (dietaryEnergyAction?.kilocalories ?? 0) > 0

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
                    
                    if let insulinAction, showsLogInsulinButton {
                        ChatActionButton("Add \(insulinAction.units.formatted()) U \(insulinAction.type.insulinType.title)", systemImage: "syringe") {
                            onLogInsulin(ChatInsulinDraft(units: insulinAction.units, type: insulinAction.type.insulinType))
                        }
                    }

                    if let dietaryEnergyAction, showsLogDietaryEnergyButton {
                        ChatActionButton("Add \(dietaryEnergyAction.kilocalories.formatted()) kcal", systemImage: "flame") {
                            onLogDietaryEnergy(ChatDietaryEnergyDraft(kilocalories: dietaryEnergyAction.kilocalories))
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
                .animation(.snappy(duration: 0.35, extraBounce: 0.08), value: showsLogInsulinButton)
                .animation(.snappy(duration: 0.35, extraBounce: 0.08), value: showsLogDietaryEnergyButton)
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
        "Add \(carbGramsToLog.formatted()) g carbs"
    }
}
