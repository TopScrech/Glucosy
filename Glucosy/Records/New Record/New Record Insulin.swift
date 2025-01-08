import SwiftUI

struct NewRecordInsulin: View {
    @State private var date = Date()
    @State private var unitsString = ""
    @State private var purpose: InsulinType = .bolus
    
    private var units: Int? {
        Int(unitsString)
    }
    
    var body: some View {
        List {
            Section {
                DatePicker("Date", selection: $date)
                
                HStack {
                    Text("Units of Insulin")
                    
                    Spacer()
                    
                    TextField("", text: $unitsString)
                }
                
                Picker("Purpose", selection: $purpose) {
                    ForEach(InsulinType.allCases, id: \.self) { type in
                        Text(type.rawValue)
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)
            } footer: {
                Text("Basal insulin refers to the insulin used to regulate blood glucose between meals including during sleep. Bolus insulin refers to the insulin used to regulate blood glucose at meals and or to acutely address high blood glucose")
            }
        }
    }
}

#Preview {
    NewRecordInsulin()
}
