import Foundation

@available(iOS 26, *)
struct FoundationModelChatMessage: Identifiable {
    enum Role {
        case user, assistant
    }
    
    let id = UUID()
    let role: Role
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
