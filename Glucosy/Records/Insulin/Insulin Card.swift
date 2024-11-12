import SwiftUI

struct InsulinCard: View {
    private let record: Insulin
    
    init(_ record: Insulin) {
        self.record = record
    }
    
    private var icon: String {
        record.type == .basal ? "syringe.fill" : "syringe"
    }
    
    private var color: Color {
        record.type == .basal ? .purple : .yellow
    }
    
    private var value: Int {
        Int(record.value)
    }
    
    private var date: Date {
        record.date
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                
                Text(value)
                
                Spacer()
                
                Text(date, format: .dateTime.hour().minute())
            }
            
            RecordSource(record.source)
        }
    }
}

//#Preview {
//    InsulinCard()
//}
