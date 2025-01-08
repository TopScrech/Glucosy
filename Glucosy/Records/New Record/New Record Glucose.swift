import SwiftUI

struct NewRecordGlucose: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var date = Date()
    @State private var unitsString = ""
    @State private var mealTime: MealType = .unspecified
    
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
                    Text("Blood Glucose")
                        .secondary()
                    
                    Spacer()
                    
                    TextField("", text: $unitsString)
                    
                    Text("mmol/L")
                }
                
                Picker("Meal Time", selection: $mealTime) {
                    ForEach(MealType.allCases, id: \.self) { type in
                        Text(type.rawValue)
                            .tag(type)
                    }
                }
                .secondary()
            }
        }
        .navigationTitle("Blood Glucose")
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
    NewRecordGlucose()
}
