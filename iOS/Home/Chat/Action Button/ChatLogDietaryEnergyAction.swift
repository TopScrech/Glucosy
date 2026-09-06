import FoundationModels

@available(iOS 26, *)
@Generable
struct ChatLogDietaryEnergyAction {
    @Guide(description: "Positive dietary energy in kilocalories for the chosen portion, either supplied by the user or estimated from food when requested. Food calories mean kcal. Never use carbohydrate grams, portion weight, active energy, or resting energy")
    var kilocalories: Double
}
