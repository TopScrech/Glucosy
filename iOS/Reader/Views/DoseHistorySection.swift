import SwiftUI

struct DoseHistorySection: View {
    @Environment(PenReaderVM.self) private var vm
    @Environment(HealthKit.self) private var healthKit
    @EnvironmentObject private var store: ValueStore
    
    private var missingDoseCount: Int {
        matches.filter { $0 == .missing }.count
    }
    
    private var doses: [DoseEntry] {
        vm.visibleDoses(using: store.airshotFilter)
    }
    
    private var matches: [DoseHealthKitMatch] {
        vm.doseMatches(using: healthKit.insulinRecords, airshotFilter: store.airshotFilter)
    }
    
    private var doseHistoryExportText: String {
        vm.doseHistoryExportText(using: store.airshotFilter)
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
