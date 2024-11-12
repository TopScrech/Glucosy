import SwiftUI

struct GlucoseCard: View {
    private let record: Glucose
    
    init(_ record: Glucose) {
        self.record = record
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(record.value)
            }
            
            SourceName(record.source)
        }
    }
}

//#Preview {
//    GlucoseCard()
//}
