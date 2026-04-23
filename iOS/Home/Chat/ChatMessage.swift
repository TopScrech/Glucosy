import Foundation
import ChitChat

@available(iOS 26, *)
struct ChatMessage: Identifiable {
    let id = UUID()
    let role: ChatMessageRole
    var text: String
    var targetText: String
    var response: ChatAssistantResponse?
    
    var isFullyRevealed: Bool {
        text == targetText
    }
    
    init(userText: String) {
        role = .user
        text = userText
        targetText = userText
        response = nil
    }
    
    init(assistantText: String) {
        role = .assistant
        text = assistantText
        targetText = assistantText
        response = nil
    }
    
    init(response: ChatAssistantResponse) {
        role = .assistant
        text = response.outputText
        targetText = response.outputText
        self.response = response
    }
}
