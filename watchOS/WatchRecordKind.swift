import Foundation

enum WatchRecordKind: String, CaseIterable, Identifiable, Hashable {
    case glucose, insulin, carbs, weight
    
    var id: Self {
        self
    }
    
    var title: String {
        switch self {
        case .glucose:
            "Blood Glucose"
        case .insulin:
            "Insulin Delivery"
        case .carbs:
            "Carbohydrates"
        case .weight:
            "Weight"
        }
    }
    
    var systemImage: String {
        switch self {
        case .glucose:
            "drop"
        case .insulin:
            "syringe"
        case .carbs:
            "fork.knife"
        case .weight:
            "scalemass"
        }
    }
    
    var emptyState: String {
        switch self {
        case .glucose:
            "No blood glucose records yet"
        case .insulin:
            "No insulin records yet"
        case .carbs:
            "No carbohydrate records yet"
        case .weight:
            "No weight records yet"
        }
    }
}
