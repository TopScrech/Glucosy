import FoundationModels

@available(iOS 26, *)
@Generable
struct ChatAssistantResponse {
    @Guide(description: "Make it clear that the carbohydrate values are estimates. Mention carbohydrates per 100 g or 100 ml, whichever fits the product better. Mention the carbohydrates for the chosen portion whenever you provide logCarbsAction")
    var outputText: String
    
    @Guide(description: "An optional action for showing the log carbs button in the app. Use a value only when there is a clear carbohydrate estimate that the person could plausibly log right now. Use null for irrelevant questions, refusals, follow-up questions, or when the answer should not show a log button. If they gave no portion, choose a logical common portion such as 1 apple or 250 ml soup whenever possible. If that is still not clear, use 100 g or 100 ml as the portion")
    var logCarbsAction: ChatLogCarbsAction?
}
