import Foundation

struct PendingDoseWrite: Identifiable {
    let id = UUID()
    let dose: DoseEntry
}
