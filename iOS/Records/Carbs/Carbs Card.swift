import SwiftUI

struct CarbsCard: View {
    @EnvironmentObject private var storage: ValueStorage
    
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
                
                if storage.debugMode {
                    SourceName(record.source)
                }
            }
            
            Spacer()
            
            Text(record.date, format: .dateTime.hour().minute())
                .secondary()
        }
    }
}

//#Preview {
//    CarbsCard()
//}
