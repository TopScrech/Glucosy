import FoundationModels

@available(iOS 26, *)
@Generable
struct ChatAssistantResponse {
    @Guide(description: "A concise answer in the same language as the person's prompt. Make it clear that the carbohydrate values are estimates. Mention carbohydrates per 100 g or 100 ml, whichever fits the product better. Mention the carbohydrates for the chosen portion whenever you provide carbGramsToLog")
    var outputText: String
    
    @Guide(description: "The estimated grams of carbohydrate for the chosen portion. This must always be carbohydrate grams, never the portion weight, portion volume, serving size, item count, or any other measurement of the food itself. For example, if soup is 250 ml and the estimate is 8 g carbs per 100 ml, carbGramsToLog must be 20, not 250. If they gave no portion, choose a logical common portion such as 1 apple or 250 ml soup whenever possible. If that is still not clear, use 100 g or 100 ml as the portion. Use null when you refuse or need a follow-up question")
    var carbGramsToLog: Double?
}
