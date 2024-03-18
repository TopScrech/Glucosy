import SwiftUI

struct HealthKitCard: View {
    private let glucose: Glucose
    
    init(_ glucose: Glucose) {
        self.glucose = glucose
    }
    
    var date: String {
        glucose.date.shortDateTime
    }
    
    var source: String {
        String(glucose.source[..<(glucose.source.lastIndex(of: " ") ?? glucose.source.endIndex)])
    }
    
    var body: some View {
        HStack {
            Text("\(glucose.value.units)")
                .bold()
            
            Text("\(source)")
            
            Spacer()
            
            Text("\(date)")
                .footnote()
                .foregroundStyle(.secondary)
        }
        .monospacedDigit()
    }
}

#Preview {
    List {
        HealthKitCard(History.test.storedValues.first!)
    }
    .darkSchemePreferred()
}
