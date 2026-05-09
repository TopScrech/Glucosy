import Foundation

@Observable
final class NovoPenWriteConfirmationVM {
    var insulinType: InsulinType = .bolus
    var penTitle = ""
    var savedDoses: [NovoPenSavedDose] = []
    
    func present(
        savedDoses: [NovoPenSavedDose],
        insulinType: InsulinType,
        penTitle: String
    ) {
        self.insulinType = insulinType
        self.penTitle = penTitle
        self.savedDoses = savedDoses.sorted { $0.dose.timestamp > $1.dose.timestamp }
    }
    
    func dismiss() {
        penTitle = ""
        savedDoses = []
    }
    
    func save(
        doses: [DoseEntry],
        insulinType: InsulinType,
        penTitle: String,
        using healthKit: HealthKit
    ) async throws {
        var savedDoses: [NovoPenSavedDose] = []
        
        for dose in doses.sorted(by: { $0.timestamp < $1.timestamp }) {
            let insulinRecord = try await healthKit.writeInsulin(
                value: dose.units,
                type: insulinType,
                date: dose.timestamp
            )
            
            savedDoses.append(
                NovoPenSavedDose(
                    dose: dose,
                    insulinRecord: insulinRecord
                )
            )
        }
        
        _ = try? await healthKit.reloadInsulinRecords()
        
        present(
            savedDoses: savedDoses,
            insulinType: insulinType,
            penTitle: penTitle
        )
    }
    
    func remove(_ savedDose: NovoPenSavedDose, using healthKit: HealthKit) {
        healthKit.deleteInsulin(savedDose.insulinRecord)
        savedDoses.removeAll { $0.id == savedDose.id }
    }
}
