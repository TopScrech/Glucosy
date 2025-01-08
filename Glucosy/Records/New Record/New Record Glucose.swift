import SwiftUI

struct NewRecordGlucose: View {
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
                
                DatePicker("Time", selection: $date, displayedComponents: .hourAndMinute)
                
                HStack {
                    Text("Blood Glucose")
                    
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
            }
        }
    }
}

#Preview {
    NewRecordGlucose()
}
