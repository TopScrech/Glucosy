import Foundation

@Observable
final class NovoPenWriteConfirmationVM {
    var insulinType: InsulinType = .bolus
    var isWriting = false
    var pendingDoses: [PendingDoseWrite] = []
    var penTitle = ""
    var selectedDoseIDs: Set<PendingDoseWrite.ID> = []
    
    var selectedDoseCount: Int {
        selectedDoseIDs.count
    }
    
    var selectedDoses: [PendingDoseWrite] {
        pendingDoses.filter { selectedDoseIDs.contains($0.id) }
    }
    
    func present(
        doses: [DoseEntry],
        insulinType: InsulinType,
        penTitle: String
    ) {
        let pendingDoses = doses
            .sorted { $0.timestamp > $1.timestamp }
            .map(PendingDoseWrite.init(dose:))
        
        self.insulinType = insulinType
        self.penTitle = penTitle
        self.pendingDoses = pendingDoses
        selectedDoseIDs = Set(pendingDoses.map(\.id))
    }
    
    func dismiss() {
        penTitle = ""
        pendingDoses = []
        selectedDoseIDs = []
        isWriting = false
    }
    
    func toggleSelection(for pendingDose: PendingDoseWrite) {
        if selectedDoseIDs.contains(pendingDose.id) {
            selectedDoseIDs.remove(pendingDose.id)
            return
        }
        
        selectedDoseIDs.insert(pendingDose.id)
    }
    
    func writeSelectedDoses(using healthKit: HealthKit) async throws {
        guard !isWriting else { return }
        
        isWriting = true
        defer { isWriting = false }
        
        for pendingDose in selectedDoses.sorted(by: { $0.dose.timestamp < $1.dose.timestamp }) {
            try await healthKit.writeInsulin(
                value: pendingDose.dose.units,
                type: insulinType,
                date: pendingDose.dose.timestamp
            )
        }
        
        _ = try? await healthKit.reloadInsulinRecords()
    }
}
