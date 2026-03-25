import SwiftUI

struct NewRecordGlucose: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: ValueStore
    
    @State private var date = Date()
    @State private var unitsString = ""
    @State private var mealTime: MealType = .unspecified
    
    private var units: Double? {
        Double(unitsString)
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
                        .multilineTextAlignment(.trailing)
                    
                    Text(store.glucoseUnit.title)
                }
                
                Picker("Meal Time", selection: $mealTime) {
                    ForEach(MealType.allCases) {
                        Text($0.title)
                            .tag($0)
                    }
                }
                .secondary()
            }
        }
        .navigationTitle("Blood Glucose")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel", role: .destructive) {
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
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
