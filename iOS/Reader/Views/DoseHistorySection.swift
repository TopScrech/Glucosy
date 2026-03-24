import SwiftUI
import UIKit

struct DoseHistorySection: View {
    let doses: [DoseEntry]
    let matches: [DoseHealthKitMatch]
    let doseHistoryExportText: String
    
    private var missingDoseCount: Int {
        matches.filter { $0 == .missing }.count
    }
    
    var body: some View {
        Section("Dose History") {
            Button("Copy Dose History", systemImage: "doc.on.doc") {
                UIPasteboard.general.string = doseHistoryExportText
            }
            .disabled(doseHistoryExportText.isEmpty)
            
            if missingDoseCount > 0 {
                Text("\(missingDoseCount) NovoPen records not found in loaded HealthKit insulin")
                    .foregroundStyle(.orange)
            }
            
            ForEach(doses.indices, id: \.self) {
                DoseRow(dose: doses[$0], match: matches[$0])
            }
        }
    }
}
