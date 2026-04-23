import Foundation

@available(iOS 26, *)
struct FoundationModelChatMessage: Identifiable {
    enum Role {
        case user, assistant
    }
    
    let id = UUID()
    let role: Role
    var text: String
    var response: ChatAssistantResponse?
    
    init(userText: String) {
        role = .user
        text = userText
        response = nil
    }
    
    init(assistantText: String) {
        role = .assistant
        text = assistantText
        response = nil
    }
    
    init(response: ChatAssistantResponse) {
        role = .assistant
        text = response.outputText
        self.response = response
    }
}
