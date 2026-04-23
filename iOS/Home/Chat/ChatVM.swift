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
    @ObservationIgnored private var typingTask: Task<Void, Never>?
    
    @ObservationIgnored private let instructions = Instructions("""
        You are the in-app Glucosy assistant
        You can only estimate the amount of carbohydrates in a given product
        If the user asks for anything else, briefly refuse and explain that you only estimate carbs in products
        Return the answer using the provided response schema
        Write outputText only in the same language as the prompt
        Keep outputText concise
        Make it clear that every carbohydrate value is an estimate
        Always mention carbohydrates per 100 g or 100 ml, whichever fits the product better
        logCarbsAction is optional and should only be present when there is a clear carbohydrate estimate that the person could log right now
        Omit logCarbsAction for irrelevant questions, refusals, follow-up questions, greetings, thanks, and any reply where showing a log button would not be useful
        If logCarbsAction is present, its carbGrams must always be grams of carbohydrate for the chosen portion
        If logCarbsAction is present, its carbGrams must never be the portion weight, the portion volume, the serving size, the item count, or any other measurement of the food itself
        If the user gave a portion size, logCarbsAction.carbGrams must be the estimated carbohydrate grams for exactly that portion size
        If the user did not give a portion size, choose a logical common portion such as 1 apple or 250 ml soup whenever possible
        If a logical common portion is not clear, use 100 g or 100 ml as the portion for logCarbsAction.carbGrams
        If the product or portion is too unclear to estimate responsibly, ask one short follow-up question and set logCarbsAction to null
        If you refuse because the user asked for something outside carbohydrate estimation, set logCarbsAction to null
        Double check the final numeric value before answering so logCarbsAction.carbGrams is the estimated carbohydrate grams, not the portion amount
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
        
        typingTask?.cancel()
        typingTask = nil
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
            startTypingTaskIfNeeded()
            prompt = ""
            
            do {
                await updateTranscriptTokenUsage()
                
                let stream = session.streamResponse(
                    to: userPrompt,
                    generating: ChatAssistantResponse.self
                )
                
                for try await snapshot in stream {
                    guard let messageIndex = messages.indices.last else {
                        continue
                    }
                    
                    if let outputText = snapshot.content.outputText {
                        messages[messageIndex].targetText = outputText
                        startTypingTaskIfNeeded()
                    }
                }
                
                let response = try await stream.collect()
                
                guard let messageIndex = messages.indices.last else {
                    isResponding = false
                    return
                }
                
                messages[messageIndex].targetText = response.content.outputText
                messages[messageIndex].response = response.content
                startTypingTaskIfNeeded()
                await updateTranscriptTokenUsage()
                isResponding = false
            } catch {
                guard let messageIndex = messages.indices.last else {
                    isResponding = false
                    return
                }
                
                messages[messageIndex].targetText = error.localizedDescription
                startTypingTaskIfNeeded()
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
    
    private func startTypingTaskIfNeeded() {
        guard typingTask == nil else {
            return
        }
        
        typingTask = Task { [weak self] in
            await self?.runTypingLoop()
        }
    }
    
    private func runTypingLoop() async {
        while !Task.isCancelled {
            guard let messageIndex = messages.lastIndex(where: { $0.role == .assistant }) else {
                break
            }
            
            let message = messages[messageIndex]
            let displayedCount = message.text.count
            let targetText = message.targetText
            let targetCount = targetText.count
            
            if message.text == targetText {
                if !isResponding {
                    break
                }
                
                do {
                    try await Task.sleep(for: .milliseconds(40))
                } catch {
                    break
                }
                
                continue
            }
            
            if !targetText.hasPrefix(message.text) {
                let commonPrefixCount = commonPrefixCount(
                    between: message.text,
                    and: targetText
                )
                messages[messageIndex].text = String(targetText.prefix(commonPrefixCount))
                continue
            }
            
            let remainingCount = targetCount - displayedCount
            let step = switch remainingCount {
            case 25...:
                4
            case 10...24:
                2
            default:
                1
            }
            
            messages[messageIndex].text = String(targetText.prefix(min(displayedCount + step, targetCount)))
            
            do {
                try await Task.sleep(for: .milliseconds(18))
            } catch {
                break
            }
        }
        
        typingTask = nil
    }
    
    private func commonPrefixCount(between lhs: String, and rhs: String) -> Int {
        zip(lhs, rhs)
            .prefix { $0 == $1 }
            .count
    }
}
