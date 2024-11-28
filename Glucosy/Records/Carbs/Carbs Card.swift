import SwiftUI

struct CarbsCard: View {
    private let record: Carbohydrates
    
    init(_ record: Carbohydrates) {
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
//    CarbsCard()
//}
