import FoundationModels

@available(iOS 26, *)
@Generable
struct ChatLogCarbsAction {
    @Guide(description: "The estimated grams of carbohydrate for the chosen portion. This must always be carbohydrate grams, never the portion weight, portion volume, serving size, item count, or any other measurement of the food itself. For example, if soup is 250 ml and the estimate is 8 g carbs per 100 ml, carbGrams must be 20, not 250")
    var carbGrams: Double
}
