import SwiftUI

struct GlucoseCard: View {
    @EnvironmentObject private var store: ValueStore
    
    private let record: Glucose
    
    init(_ record: Glucose) {
        self.record = record
    }
    
    private var sourceId: String {
        record.sample.sourceRevision.source.bundleIdentifier
    }
    
    var body: some View {
        HStack(spacing: 16) {
            SourceImage(sourceId)
            
            VStack(alignment: .leading) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(record.formattedValue(in: store.glucoseUnit))
                        .title3(.semibold, design: .rounded)

                    Text(store.glucoseUnit.title)
                        .caption()
                        .secondary()
                }
                
                if store.debugMode {
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
//    GlucoseCard()
//    .darkSchemePreferred()
//}
