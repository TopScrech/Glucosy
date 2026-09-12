import FoundationModels

@available(iOS 26, *)
@Generable
struct ChatAssistantResponse {
    @Guide(description: "A concise reply in the user's language. For food estimates, label estimates and mention the requested nutrients per 100 g or 100 ml and the chosen portion. Dietary energy is in kcal. For direct logging requests, repeat the supplied amount without calling it an estimate. Explain that the user can review and save with the buttons, never claim a record was saved")
    var outputText: String

    @Guide(description: "An optional carbs entry action for a clear food estimate or an explicit request to log a supplied carbohydrate amount in grams. Omit when the amount or unit is unclear or a button would not be useful")
    var logCarbsAction: ChatLogCarbsAction?

    @Guide(description: "An optional insulin entry action only for an explicit logging request with a user-supplied dose in units and an explicit basal or bolus type. Omit for missing details, dosing advice, or inferred doses")
    var logInsulinAction: ChatLogInsulinAction?

    @Guide(description: "An optional dietary energy entry action for an explicit calorie logging request or a requested food calorie estimate with a clear portion. Food calories mean kcal. Omit for unclear amounts, energy expenditure, and unrelated replies")
    var logDietaryEnergyAction: ChatLogDietaryEnergyAction?
}
