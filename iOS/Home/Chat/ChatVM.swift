import Foundation
import OSLog
import ChitChat

#if canImport(FoundationModels)
import FoundationModels
#endif

@available(iOS 26, *)
@Observable
final class ChatVM {
    var prompt = ""
    var messages: [ChatMessage] = []
    var isResponding = false
    var transcriptTokens = 0.0
    var contextWindow = 0.0
    
    @ObservationIgnored private let logger = Logger()
    @ObservationIgnored private let model = SystemLanguageModel.default
    
    @ObservationIgnored private let instructions = Instructions("""
        You are the in-app Glucosy assistant
        You can only estimate the amount of carbohydrates in a given product
        If the user asks for anything else, briefly refuse and explain that you only estimate carbs in products
        Provide concise answers
        Answer only in the same language as the prompt
        Ask a short follow-up question if the product or portion size is unclear
        Prefer estimates in grams of carbohydrates
        Make it clear when an answer is an estimate
        Always mention carbohydrates per 100 g
        Mention carbohydrates per portion whenever the portion is given, inferable, or otherwise appropriate
        Do not claim to have taken actions inside the app
        Do not invent certainty
        """)
    
    @ObservationIgnored private var session: LanguageModelSession
    @ObservationIgnored private var context = ""
    
    var tokenUsage: Double {
        guard contextWindow > 0 else {
            return 0
        }
        
        return transcriptTokens / contextWindow
    }
    
    init() {
        session = LanguageModelSession(
            model: model,
            instructions: instructions
        )
    }
    
    func printContextSize() {
        let contextSize = model.contextSize
        logger.info("Context size: \(contextSize)")
        
        contextWindow = Double(contextSize)
    }
    
    func refreshContext(using healthKit: HealthKit, glucoseUnit: GlucoseUnit) {
        context = ChatContextSnapshot(
            healthKit: healthKit,
            glucoseUnit: glucoseUnit
        )
        .promptContext
    }
    
    func startNewChat() {
        guard !isResponding else {
            return
        }
        
        prompt = ""
        messages = []
        transcriptTokens = 0
        session = makeSession()
    }
    
    func sendPrompt() async {
        let userPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userPrompt.isEmpty else {
            return
        }
        guard !isResponding else {
            return
        }
        
        switch model.availability {
        case .available:
            isResponding = true
            messages.append(ChatMessage(role: .user, text: userPrompt))
            messages.append(ChatMessage(role: .assistant, text: ""))
            prompt = ""
            
            do {
                let stream = session.streamResponse(to: contextualPrompt(for: userPrompt))
                
                for try await snapshot in stream {
                    guard let messageIndex = messages.indices.last else {
                        continue
                    }
                    
                    messages[messageIndex].text = snapshot.content
                }
                
                _ = try await stream.collect()
                await updateTranscriptTokenUsage()
                isResponding = false
            } catch {
                guard let messageIndex = messages.indices.last else {
                    isResponding = false
                    return
                }
                
                messages[messageIndex].text = error.localizedDescription
                logger.error("\(error.localizedDescription)")
                isResponding = false
            }
            
        case .unavailable(let reason):
            messages.append(ChatMessage(role: .assistant, text: "Model unavailable: \(String(describing: reason))"))
            logger.error("\(String(describing: reason))")
        }
    }
    
    private func contextualPrompt(for userPrompt: String) -> String {
        """
        Glucosy context
        \(context)
        
        User question
        \(userPrompt)
        """
    }
    
    private func updateTranscriptTokenUsage() async {
        guard #available(iOS 26.4, visionOS 26.4, *) else {
            return
        }
        
        do {
            let transcriptTokenUsage = try await model.tokenCount(for: session.transcript)
            logger.info("Transcript tokens: \(transcriptTokenUsage)")
            transcriptTokens = Double(transcriptTokenUsage)
        } catch {
            logger.error("\(error.localizedDescription)")
        }
    }
    
    private func makeSession() -> LanguageModelSession {
        LanguageModelSession(
            model: model,
            instructions: instructions
        )
    }
}
