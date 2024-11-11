import SwiftUI

struct GlucoseCard: View {
    private let record: HealthRecord
    
    init(_ record: HealthRecord) {
        self.record = record
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(record.value)
            }
            
            Text(record.source)
                .footnote()
                .secondary()
        }
    }
}

//#Preview {
//    GlucoseCard()
//}
