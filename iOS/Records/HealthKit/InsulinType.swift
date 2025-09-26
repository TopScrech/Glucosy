enum InsulinType: String, Identifiable, Codable, CaseIterable {
    case bolus, basal
    
    var id: String {
        rawValue
    }
}
