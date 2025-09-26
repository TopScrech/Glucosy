enum MealType: String, Identifiable, CaseIterable {
    case unspecified, beforeMeal, afterMeal
    
    var id: String {
        rawValue
    }
}
