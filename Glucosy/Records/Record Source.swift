import SwiftUI

struct RecordSource: View {
    private let source: String
    
    init(_ source: String) {
        self.source = source
    }
    
    var body: some View {
        Text(source)
            .footnote()
            .secondary()
    }
}

//#Preview {
//    RecordSource()
//}
