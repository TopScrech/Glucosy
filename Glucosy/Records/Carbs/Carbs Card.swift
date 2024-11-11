import SwiftUI

struct CarbsCard: View {
    private let record: Carbohydrates
    
    init(_ record: Carbohydrates) {
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
//    CarbsCard()
//}
