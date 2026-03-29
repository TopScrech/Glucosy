import SwiftUI

struct NewRecordCarbs: View {
    @Environment(HealthKit.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    @State private var date = Date()
    @State private var unitsString = ""
    
    private var units: Double? {
        Double(unitsString.replacing(",", with: "."))
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
                        .keyboardType(.decimalPad)
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
                    guard let units else {
                        return
                    }

                    vm.writeCarbs(value: units, date: date)
                    dismiss()
                }
                .bold()
                .disabled(units == nil)
            }
        }
    }
}

#Preview {
    NewRecordCarbs()
        .darkSchemePreferred()
        .environment(HealthKit())
}
