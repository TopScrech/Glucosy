import SwiftUI

struct NovoPenPendingDoseRow: View {
    let pendingDose: PendingDoseWrite
    let isSelected: Bool
    let toggleSelection: () -> Void
    
    var body: some View {
        Button(action: toggleSelection) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                
                Text(pendingDose.dose.units, format: .number.precision(.fractionLength(0...1)))
                
                Spacer()
                
                Text(pendingDose.dose.timestamp, format: .dateTime.day().month().hour().minute())
                    .secondary()
            }
        }
        .buttonStyle(.plain)
    }
}
