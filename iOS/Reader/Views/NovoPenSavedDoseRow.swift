import ScrechKit

struct NovoPenSavedDoseRow: View {
    let savedDose: NovoPenSavedDose
    
    var body: some View {
        HStack {
            Text(savedDose.dose.units, format: .number.precision(.fractionLength(0...1)))
            
            Spacer()
            
            Text(savedDose.timestampLabel)
                .secondary()
        }
    }
}
