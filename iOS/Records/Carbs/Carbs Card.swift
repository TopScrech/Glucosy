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
                Text(Int(record.value))
                
                if storage.debugMode {
                    SourceName(record.source)
                }
            }
            
            Spacer()
            
            Text(record.date, format: .dateTime.hour().minute())
                .secondary()
        }
#if DEBUG
        .contextMenu {
            Button {
                UIPasteboard.general.string = record.source
            } label: {
                Text("Copy Source")
                
                Text(record.source)
                
                Image(systemName: "doc.on.doc")
            }
        }
#endif
    }
}

//#Preview {
//    CarbsCard()
//}
