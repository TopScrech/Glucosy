import Foundation

struct NovoPenSavedDose: Identifiable {
    let id = UUID()
    let dose: DoseEntry
    let insulinRecord: Insulin
}
