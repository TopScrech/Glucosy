import SwiftUI

struct GlucoseCard: View {
    private let record: Glucose
    
    init(_ record: Glucose) {
        self.record = record
    }
    
    private var sourceId: String {
        record.sample.sourceRevision.source.bundleIdentifier
    }
    
    var body: some View {
        HStack {
            SourceImage(sourceId)
            
            VStack(alignment: .leading) {
                Text(record.value)
                
                SourceName(record.source)
            }
            
            Spacer()
            
            Text(record.date, format: .dateTime.hour().minute())
        }
    }
}

//#Preview {
//    GlucoseCard()
//}
