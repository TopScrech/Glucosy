enum MealType: String, Identifiable, CaseIterable {
    case unspecified, beforeMeal, afterMeal
    
    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .unspecified: String(localized: "Unspecified")
        case .beforeMeal: String(localized: "Before Meal")
        case .afterMeal: String(localized: "After Meal")
        }
    }
}
