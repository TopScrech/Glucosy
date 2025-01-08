import SwiftUI

struct NewRecordCarbs: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var date = Date()
    @State private var unitsString = ""
    
    private var units: Int? {
        Int(unitsString)
    }
    
    var body: some View {
        List {
            Section {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .secondary()
                
                DatePicker("Time", selection: $date, displayedComponents: .hourAndMinute)
                    .secondary()
                
                HStack {
                    Text("g")
                        .secondary()
                    
                    Spacer()
                    
                    TextField("", text: $unitsString)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .navigationTitle("Carbohydrates")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add") {
                    
                }
                .bold()
            }
        }
    }
}

#Preview {
    NewRecordCarbs()
}
