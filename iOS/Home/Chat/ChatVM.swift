import Foundation
import ChitChat
import OSLog

#if canImport(FoundationModels)
import FoundationModels
#endif

@available(iOS 26, *)
@Observable
final class ChatVM {
    private enum ModelProvider {
        case local, privateCloudCompute
    }
    
    var prompt = ""
    var messages: [ChatMessage] = []
    var isResponding = false
    var transcriptTokens = 0.0
    var contextWindow = 0.0
    
    @ObservationIgnored private let logger = Logger()
    @ObservationIgnored private let localModel = SystemLanguageModel.default
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
    @ObservationIgnored private var modelProvider: ModelProvider
    
    var tokenUsage: Double {
        guard contextWindow > 0 else {
            return 0
        }
        
        return transcriptTokens / contextWindow
    }
    
    init() {
        modelProvider = Self.preferredModelProvider()
        session = Self.makeSession(for: modelProvider, instructions: instructions)
    }
    
    func printContextSize() async {
        do {
            let contextSize = try await contextSize(for: modelProvider)
            logger.info("Context size: \(contextSize)")
            
            contextWindow = Double(contextSize)
        } catch {
            logger.error("\(error.localizedDescription)")
            contextWindow = Double(localModel.contextSize)
        }
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
        modelProvider = Self.preferredModelProvider(logger: logger)
        session = Self.makeSession(for: modelProvider, instructions: instructions)
    }
    
    func sendPrompt() async {
        let userPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !userPrompt.isEmpty else { return }
        guard !isResponding else { return }
        
        if messages.isEmpty {
            prepareSessionForNewChat()
        }
        
        if case .local = modelProvider, let unavailableReason = localUnavailableReason {
            messages.append(ChatMessage(assistantText: "Model unavailable: \(unavailableReason)", name: modelDisplayName))
            logger.error("\(unavailableReason)")
            return
        }
        
        isResponding = true
        messages.append(ChatMessage(userText: userPrompt))
        messages.append(ChatMessage(assistantText: "", name: modelDisplayName))
        startTypingTaskIfNeeded()
        prompt = ""
        
        do {
            try await streamResponse(to: userPrompt)
        } catch {
            guard modelProvider == .privateCloudCompute else {
                finishResponse(with: error)
                return
            }
            
            logger.error("Private Cloud Compute failed: \(error.localizedDescription)")
            modelProvider = .local
            session = Self.makeSession(for: .local, instructions: instructions)
            
            if let messageIndex = messages.indices.last {
                messages[messageIndex].text = ""
                messages[messageIndex].targetText = ""
                messages[messageIndex].response = nil
                messages[messageIndex].name = "Private Cloud Compute failed, using \(modelDisplayName)"
            }
            
            do {
                try await streamResponse(to: userPrompt)
            } catch {
                finishResponse(with: error)
                return
            }
        }
        
        isResponding = false
    }
    
    private func updateTranscriptTokenUsage() async {
        if #available(anyAppleOS 27, *) {
            transcriptTokens = Double(session.usage.totalTokenCount)
            return
        }
        
        guard #available(anyAppleOS 26.4, *) else {
            return
        }
        
        do {
            let transcriptTokenUsage = try await localModel.tokenCount(for: session.transcript)
            logger.info("Transcript tokens: \(transcriptTokenUsage)")
            transcriptTokens = Double(transcriptTokenUsage)
        } catch {
            logger.error("\(error.localizedDescription)")
        }
    }
    
    private func streamResponse(to userPrompt: String) async throws {
        await updateTranscriptTokenUsage()
        
        if #available(anyAppleOS 27, *) {
            let stream = session.streamResponse(
                to: userPrompt,
                generating: ChatAssistantResponse.self,
                contextOptions: contextOptionsForCurrentModel()
            )
            
            try await consume(stream)
        } else {
            let stream = session.streamResponse(
                to: userPrompt,
                generating: ChatAssistantResponse.self
            )
            
            try await consume(stream)
        }
        
        await updateTranscriptTokenUsage()
    }
    
    private func consume(_ stream: sending LanguageModelSession.ResponseStream<ChatAssistantResponse>) async throws {
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
            return
        }
        
        messages[messageIndex].targetText = response.content.outputText
        messages[messageIndex].response = response.content
        
        startTypingTaskIfNeeded()
    }
    
    private func finishResponse(with error: any Error) {
        if let messageIndex = messages.indices.last {
            messages[messageIndex].targetText = error.localizedDescription
            startTypingTaskIfNeeded()
        }
        
        logger.error("\(error.localizedDescription)")
        isResponding = false
    }
    
    private var localUnavailableReason: String? {
        switch localModel.availability {
        case .available:
            nil
            
        case .unavailable(let reason):
            String(describing: reason)
        }
    }
    
    private var modelDisplayName: String {
        switch modelProvider {
        case .local:
            if #available(anyAppleOS 27, *), localModel.capabilities.contains(.reasoning) {
                return "Foundation Models, Deep Reasoning"
            }
            
            return "Foundation Models"
            
        case .privateCloudCompute:
            if #available(anyAppleOS 27, *), PrivateCloudComputeLanguageModel().capabilities.contains(.reasoning) {
                return "Private Cloud Compute, Deep Reasoning"
            }
            
            return "Private Cloud Compute"
        }
    }
    
    @available(anyAppleOS 27, *)
    private func contextOptionsForCurrentModel() -> ContextOptions {
        switch modelProvider {
        case .local:
            if localModel.capabilities.contains(.reasoning) {
                return ContextOptions(reasoningLevel: .deep)
            }
            
        case .privateCloudCompute:
            if PrivateCloudComputeLanguageModel().capabilities.contains(.reasoning) {
                return ContextOptions(reasoningLevel: .deep)
            }
        }
        
        return ContextOptions()
    }
    
    private func prepareSessionForNewChat() {
        modelProvider = Self.preferredModelProvider(logger: logger)
        session = Self.makeSession(for: modelProvider, instructions: instructions)
    }
    
    private func contextSize(for modelProvider: ModelProvider) async throws -> Int {
        switch modelProvider {
        case .local:
            localModel.contextSize
            
        case .privateCloudCompute:
            if #available(anyAppleOS 27, *) {
                try await PrivateCloudComputeLanguageModel().contextSize
            } else {
                localModel.contextSize
            }
        }
    }
    
    private static func preferredModelProvider(logger: Logger? = nil) -> ModelProvider {
        if #available(anyAppleOS 27, *) {
            switch PrivateCloudComputeLanguageModel().availability {
            case .available:
                logger?.info("Using Private Cloud Compute")
                return .privateCloudCompute
                
            case .unavailable(let reason):
                logger?.info("Private Cloud Compute unavailable: \(String(describing: reason))")
            }
        }
        
        logger?.info("Using Foundation Models")
        return .local
    }
    
    private static func makeSession(for modelProvider: ModelProvider, instructions: Instructions) -> LanguageModelSession {
        switch modelProvider {
        case .local:
            LanguageModelSession(
                model: SystemLanguageModel.default,
                instructions: instructions
            )
            
        case .privateCloudCompute:
            if #available(anyAppleOS 27, *) {
                LanguageModelSession(
                    model: PrivateCloudComputeLanguageModel(),
                    instructions: instructions
                )
            } else {
                LanguageModelSession(
                    model: SystemLanguageModel.default,
                    instructions: instructions
                )
            }
        }
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
            case 25...: 4
            case 10...24: 2
            default: 1
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
