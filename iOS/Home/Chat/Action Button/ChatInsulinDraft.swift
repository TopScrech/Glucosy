import Foundation

struct ChatInsulinDraft: Identifiable {
    let id = UUID()
    let units: Double
    let type: InsulinType
}
