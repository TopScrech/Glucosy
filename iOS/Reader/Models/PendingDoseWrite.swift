import Foundation

struct PendingDoseWrite: Identifiable, Hashable {
    let id = UUID()
    let dose: DoseEntry
}
