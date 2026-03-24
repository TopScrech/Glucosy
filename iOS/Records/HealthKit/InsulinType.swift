enum InsulinType: String, Identifiable, Codable, CaseIterable {
    case bolus, basal
    
    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .bolus: String(localized: "Bolus")
        case .basal: String(localized: "Basal")
        }
    }
}
