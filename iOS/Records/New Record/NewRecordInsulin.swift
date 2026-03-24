import SwiftUI

struct NewRecordInsulin: View {
    @Environment(\.dismiss) private var dismiss
    
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
                    .secondary()
                
                HStack {
                    Text("Units of Insulin")
                        .secondary()
                    
                    Spacer()
                    
                    TextField("", text: $unitsString)
                        .multilineTextAlignment(.trailing)
                }
                
                VStack(alignment: .leading) {
                    Text("Purpose")
                    
                    Picker("Purpose", selection: $purpose) {
                        ForEach(InsulinType.allCases) {
                            Text($0.title)
                                .tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .secondary()
            } footer: {
                Text("Basal insulin refers to the insulin used to regulate blood glucose between meals including during sleep. Bolus insulin refers to the insulin used to regulate blood glucose at meals and or to acutely address high blood glucose")
            }
        }
        .navigationTitle("Insulin Delivery")
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
    NavigationView {
        NewRecordInsulin()
    }
    .darkSchemePreferred()
}
