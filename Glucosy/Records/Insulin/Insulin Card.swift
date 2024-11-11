import SwiftUI

struct InsulinCard: View {
    private let record: Insulin
    
    init(_ record: Insulin) {
        self.record = record
    }
    
    var body: some View {
        VStack {
            HStack {
                
            }
            
            RecordSource(record.source)
        }
    }
}

//#Preview {
//    InsulinCard()
//}
