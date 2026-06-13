import Foundation
import ChitChat

@available(iOS 26, *)
struct ChatMessage: Identifiable {
    let id = UUID()
    let role: ChatMessageRole
    var name: String?
    var text: String
    var targetText: String
    var response: ChatAssistantResponse?
    
    var isFullyRevealed: Bool {
        text == targetText
    }
    
    var showsStartNewChatAction: Bool {
        isFullyRevealed && role == .assistant && targetText == "Exceeded model context window size"
    }
    
    init(userText: String) {
        role = .user
        name = nil
        text = userText
        targetText = userText
        response = nil
    }
    
    init(assistantText: String, name: String? = nil) {
        role = .assistant
        self.name = name
        text = assistantText
        targetText = assistantText
        response = nil
    }
    
    init(response: ChatAssistantResponse, name: String? = nil) {
        role = .assistant
        self.name = name
        text = response.outputText
        targetText = response.outputText
        self.response = response
    }
}
