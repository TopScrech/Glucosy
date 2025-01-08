import SwiftUI

struct NewRecordCarbs: View {
    @State private var date = Date()
    @State private var unitsString = ""
    
    private var units: Int? {
        Int(unitsString)
    }
    
    var body: some View {
        List {
            Section {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                
                DatePicker("Time", selection: $date, displayedComponents: .hourAndMinute)
                
                HStack {
                    Text("g")
                    
                    Spacer()
                    
                    TextField("", text: $unitsString)
                }
            }
        }
    }
}

#Preview {
    NewRecordCarbs()
}
