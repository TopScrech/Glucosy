import SwiftUI

struct CarbsCard: View {
    @EnvironmentObject private var store: ValueStore
    
    private let record: Carbs
    
    init(_ record: Carbs) {
        self.record = record
    }
    
    private var sourceId: String {
        record.sample.sourceRevision.source.bundleIdentifier
    }
    
    private var color: Color {
        .orange
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 4) {
                Image(systemName: "fork.knife")
                    .foregroundStyle(color)
                    .title2()
                
                Text(Utils.formatNumber(record.value))
                    .title3(.semibold, design: .rounded)
                
                Text("g")
                    .caption2()
                    .secondary()
            }
            .padding(10)
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
            .padding(1)
            .background(color, in: .rect(cornerRadius: 17))
            
            HStack(spacing: 4) {
                Text(record.date, format: .dateTime.hour().minute())
                    .secondary()
                    .caption2()
                
                if store.debugMode {
                    SourceImage(sourceId)
                }
            }
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
//    .darkSchemePreferred()
//}
