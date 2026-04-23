import Foundation
import OSLog

#if canImport(FoundationModels)
import FoundationModels
#endif

@available(iOS 26, *)
@Observable
final class ChatVM {
    var prompt = ""
    var messages: [FoundationModelChatMessage] = []
    var isResponding = false
    var transcriptTokens = 0.0
    var contextWindow = 0.0
    
    @ObservationIgnored private let logger = Logger()
    @ObservationIgnored private let model = SystemLanguageModel.default
    
    @ObservationIgnored private let instructions = Instructions("""
        You are the in-app Glucosy assistant
        You can only estimate the amount of carbohydrates in a given product
        If the user asks for anything else, briefly refuse and explain that you only estimate carbs in products
        Return the answer using the provided response schema
        Write outputText only in the same language as the prompt
        Keep outputText concise
        Make it clear that every carbohydrate value is an estimate
        Always mention carbohydrates per 100 g or 100 ml, whichever fits the product better
        carbGramsToLog must always be grams of carbohydrate for the chosen portion
        carbGramsToLog must never be the portion weight, the portion volume, the serving size, the item count, or any other measurement of the food itself
        If the user gave a portion size, carbGramsToLog must be the estimated carbohydrate grams for exactly that portion size
        If the user did not give a portion size, choose a logical common portion such as 1 apple or 250 ml soup whenever possible
        If a logical common portion is not clear, use 100 g or 100 ml as the portion for carbGramsToLog
        If the product or portion is too unclear to estimate responsibly, ask one short follow-up question and set carbGramsToLog to null
        If you refuse because the user asked for something outside carbohydrate estimation, set carbGramsToLog to null
        Double check the final numeric value before answering so carbGramsToLog is the estimated carbohydrate grams, not the portion amount
        Do not claim to have taken actions inside the app
        Do not invent certainty
        """)
    
    @ObservationIgnored private var session: LanguageModelSession
    
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
            messages.append(FoundationModelChatMessage(userText: userPrompt))
            messages.append(FoundationModelChatMessage(assistantText: ""))
            prompt = ""
            
            do {
                let stream = session.streamResponse(
                    to: userPrompt,
                    generating: ChatAssistantResponse.self
                )
                
                for try await snapshot in stream {
                    guard let messageIndex = messages.indices.last else {
                        continue
                    }
                    
                    if let outputText = snapshot.content.outputText {
                        messages[messageIndex].text = outputText
                    }
                }
                
                let response = try await stream.collect()
                
                guard let messageIndex = messages.indices.last else {
                    isResponding = false
                    return
                }
                
                messages[messageIndex].text = response.content.outputText
                messages[messageIndex].response = response.content
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
            messages.append(FoundationModelChatMessage(assistantText: "Model unavailable: \(String(describing: reason))"))
            logger.error("\(String(describing: reason))")
        }
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
