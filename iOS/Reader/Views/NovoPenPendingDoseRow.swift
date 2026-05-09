import SwiftUI

struct NovoPenPendingDoseRow: View {
    let pendingDose: PendingDoseWrite
    
    var body: some View {
        HStack {
            Text(pendingDose.dose.units, format: .number.precision(.fractionLength(0...1)))
            
            Spacer()
            
            Text(pendingDose.timestampLabel)
                .foregroundStyle(.secondary)
        }
    }
}
