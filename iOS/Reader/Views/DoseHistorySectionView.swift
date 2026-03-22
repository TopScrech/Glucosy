import SwiftUI
import UIKit

struct DoseHistorySectionView: View {
    let doses: [DoseEntry]
    let doseHistoryExportText: String
    @State private var didCopyDoseHistory = false

    var body: some View {
        Section("Dose History") {
            Button("Copy Dose History", systemImage: "doc.on.doc") {
                UIPasteboard.general.string = doseHistoryExportText
                didCopyDoseHistory = true
            }
            .disabled(doseHistoryExportText.isEmpty)

            if didCopyDoseHistory {
                Text("Copied \(doses.count) doses")
                    .foregroundStyle(.secondary)
            }

            ForEach(doses) {
                DoseRowView(dose: $0)
            }
        }
    }
}
